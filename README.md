# TorDrop

TorDrop is a cli tool for securely and anonymously sharing files over the Tor network. It creates a unique .onion link to share your file.

## Features

*   **Secure & Anonymous:** All traffic is routed through the Tor network, protecting your identity and the recipient's.
*   **Easy to Use:** Simply point the tool to a file and it will generate a shareable link.
*   **Temporary Links:** Set a time-to-live (TTL) for your link to make it expire after a certain time.
*   **One-Time Downloads:** Optionally, the link can be set to expire after the first download.
*   **QR Code:** Display a QR code of the .onion link for easy sharing to mobile devices.
*   **Cross-Platform:** Works on Linux, Windows, and macOS.

## Requirements

*   Python 3.6+
*   Tor

## Installation

1.  Clone this repository:
    ```bash
    git clone https://github.com/your-username/tordrop.git
    cd tordrop
    ```

2.  Install the required Python packages:
    ```bash
    pip install -r requirements.txt
    ```

3. Place a tor file from the expert bundle suitable for your OS to the tordrop folder.

## Usage

To share a file, run the `tordrop.py` script with the path to your file:

```bash
python tordrop.py /path/to/your/file.zip
```

The script will initialize Tor and provide you with a `.onion` URL.

### Options

*   `--ttl <seconds>`: Set a time-to-live for the link in seconds.
*   `--once`: Allow the file to be downloaded only once.
*   `--simple`: Serve a simplified HTML template for low-bandwidth connections.
*   `--port <port>`: Set the local port for the web server (default: 8080).
*   `--tor-path <path>`: Specify the path to your Tor executable.
*   `--no-qr`: Do not display a QR code.
*   `--debug`: Enable debug output.

## How It Works

TorDrop uses the `stem` library to programmatically control the Tor process. It starts a new Tor process on your machine, creates an ephemeral hidden service, and forwards the hidden service port to a local Flask web server. The Flask server is responsible for serving the file.

When the script is terminated, the hidden service is destroyed, and the link becomes inaccessible.
