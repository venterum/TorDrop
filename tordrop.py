import click
import os
import time
import threading
import stem.util.log
import qrcode
import re
from tqdm import tqdm
from flask import Flask, send_from_directory, abort, render_template
from stem.process import launch_tor_with_config
from stem.control import Controller

APP_STATE = {
    "file_path": None,
    "file_dir": None,
    "file_name": None,
    "file_size": None,
    "download_once": False,
    "download_count": 0,
    "server_running": True,
    "simple_template": False,
}

def format_bytes(size):
    if size is None:
        return "N/A"
    power = 1024
    n = 0
    power_labels = {0: '', 1: 'K', 2: 'M', 3: 'G', 4: 'T'}
    while size > power and n < len(power_labels) - 1:
        size /= power
        n += 1
    return f"{size:.2f} {power_labels[n]}B"

app = Flask(__name__)

@app.route('/')
def index():
    if not APP_STATE["server_running"]:
        abort(404)
    template_name = 'simple_index.html' if APP_STATE["simple_template"] else 'index.html'
    return render_template(
        template_name,
        file_name=APP_STATE.get("file_name", "file"),
        file_size=APP_STATE.get("file_size", "N/A")
    )

@app.route('/download')
def download():
    if not APP_STATE["server_running"]:
        abort(404)
    if APP_STATE["download_once"] and APP_STATE["download_count"] > 0:
        abort(404, "This link was for a one-time download and has expired.")
    try:
        APP_STATE["download_count"] += 1
        return send_from_directory(
            APP_STATE["file_dir"],
            APP_STATE["file_name"],
            as_attachment=True
        )
    except FileNotFoundError:
        abort(404, "File not found.")
    finally:
        if APP_STATE["download_once"]:
            shutdown_thread = threading.Timer(1, shutdown_server)
            shutdown_thread.daemon = True
            shutdown_thread.start()

def run_flask_app(host, port):
    app.run(host=host, port=port, debug=False)

def shutdown_server():
    print("Download complete. Shutting down server...")
    APP_STATE["server_running"] = False
    os._exit(0)

def create_hidden_service(controller, local_port, target_port=80, debug=False):
    if debug:
        click.echo("Authenticated with Tor controller.")
        click.echo("Creating hidden service...")
    try:
        response = controller.create_ephemeral_hidden_service(
            {target_port: f"127.0.0.1:{local_port}"},
            await_publication=True
        )
        if debug:
            click.echo("Hidden service created successfully!")
        return response.service_id
    except Exception as e:
        click.echo(f"Error creating hidden service: {e}")
        return None

@click.command()
@click.argument('file_path', type=click.Path(exists=True, dir_okay=False, resolve_path=True))
@click.option('--ttl', type=int, default=0, help='Time-to-live in seconds for the link. 0 means forever.')
@click.option('--once', is_flag=True, default=False, help='Allow the file to be downloaded only once.')
@click.option('--simple', is_flag=True, default=False, help='Serve a simplified HTML template for low bandwidth.')
@click.option('--port', default=8080, help='Local port to run the web server on.')
@click.option('--tor-path', type=click.Path(exists=True, dir_okay=False), default=None, help='Path to the Tor executable.')
@click.option('--no-qr', is_flag=True, default=False, help='Do not display a QR code.')
@click.option('--debug', is_flag=True, default=False, help='Enable debug output.')
def main(file_path, ttl, once, simple, port, tor_path, no_qr, debug):
    if debug:
        stem.util.log.log_to_stdout(stem.util.log.DEBUG)

    APP_STATE["file_path"] = file_path
    APP_STATE["file_dir"] = os.path.dirname(file_path)
    APP_STATE["file_name"] = os.path.basename(file_path)
    APP_STATE["download_once"] = once
    APP_STATE["simple_template"] = simple

    try:
        file_size_bytes = os.path.getsize(file_path)
        APP_STATE["file_size"] = format_bytes(file_size_bytes)
    except OSError:
        APP_STATE["file_size"] = "N/A"

    click.echo(f"File: {APP_STATE['file_name']} ({APP_STATE['file_size']})")
    click.echo(f"Local server: http://127.0.0.1:{port}")

    flask_thread = threading.Thread(target=run_flask_app, args=("127.0.0.1", port))
    flask_thread.daemon = True
    flask_thread.start()

    tor_config = {
        'ControlPort': '9051',
        'CookieAuthentication': '1',
        'DataDirectory': os.path.join(os.getcwd(), 'tor_data'),
    }

    tor_cmd = tor_path if tor_path else 'tor'

    if not os.path.exists(tor_config['DataDirectory']):
        os.makedirs(tor_config['DataDirectory'])

    try:
        bar_format = "{desc}: {percentage:3.0f}% |{bar}|"
        with tqdm(total=100, desc="Initializing", bar_format=bar_format) as pbar:
            pbar.set_description("Bootstrapping Tor")

            def progress_handler(line):
                if "Bootstrapped " in line:
                    match = re.search(r'Bootstrapped (\d+)%', line)
                    if match:
                        percentage = int(match.group(1))
                        pbar.n = int(percentage * 0.9)
                        pbar.refresh()
                if debug:
                    tqdm.write(f"Tor: {line.strip()}")

            with launch_tor_with_config(
                tor_cmd=tor_cmd,
                config=tor_config,
                take_ownership=True,
                init_msg_handler=progress_handler
            ):
                pbar.n = 90
                pbar.set_description("Authenticating")
                pbar.refresh()
                with Controller.from_port(port=9051) as controller:
                    controller.authenticate()
                    pbar.n = 95
                    pbar.set_description("Creating Hidden Service")
                    pbar.refresh()

                    service_id = create_hidden_service(controller, port, debug=debug)

                    pbar.n = 100
                    pbar.set_description("Setup Complete!")
                    pbar.refresh()

                    if service_id:
                        onion_url = f"http://{service_id}.onion"
                        click.echo(click.echo(click.style(f"Service URL: {onion_url}", fg='green', bold=True)))
                        click.echo("Share the .onion link with the recipient.")
                        click.echo("It's recommended to use Tor Browser for downloading files.")

                        if not no_qr:
                            qr = qrcode.QRCode()
                            qr.add_data(onion_url)
                            qr.make(fit=True)
                            qr.print_ascii(invert=True)

                        click.echo("Press Ctrl+C to shut down the service.")

                        if ttl > 0:
                            click.echo(f"Link will expire in {ttl} seconds.")
                            time.sleep(ttl)
                            click.echo("TTL expired. Shutting down.")
                        else:
                            while APP_STATE["server_running"]:
                                time.sleep(1)

    except Exception as e:
        click.echo(f"Failed to launch or connect to Tor: {e}")
        click.echo("Please ensure Tor is installed and accessible.")

    finally:
        click.echo("\nShutting down the hidden service and server...")
        os._exit(0)

if __name__ == "__main__":
    main()