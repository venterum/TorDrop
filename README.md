
<img src="https://static.venterum.com/img/tordrop-768.png" alt="TorDrop Logo" align="left" width="190" height="190" align="left" style="margin-right: 20px;">

### `TorDrop`

**Securely and anonymously share files over the Tor network**

[🇷🇺 На русском языке](README_RU.md)

[![License: GPL v3](https://ziadoua.github.io/m3-Markdown-Badges/badges/LicenceGPLv3/licencegplv31.svg)](#)

---

## ⚠️ Very important text below!

TorDrop is intended for **educational and personal privacy purposes**.  
The author is **not responsible** for any misuse or illegal activity caused by using this software.  
Use responsibly and always comply with your local laws.

> **Note**: This tool will never include any Tor packages or any functionality for bypassing local Tor network blocks (such as bridges). Users are expected to install and configure Tor separately.

---

## What is this?

TorDrop is a CLI tool for securely and anonymously sharing files over the Tor network.  
It creates a unique `.onion` link to share your file, protecting both your identity and the recipient's.

---

## Features

- 🔒 **Secure & Anonymous**: All traffic routed through the Tor network  
- ⏰ **Temporary Links**: Set TTL for link expiration  
- 📥 **One-Time Downloads**: Link expires after first download  
- 📱 **QR Code Support**: Easy mobile sharing  

---

## Requirements

- Python 3.6+  
- Tor  

---

## Installation

### Prerequisites

Before installing TorDrop, ensure you have:
1. Python 3.6+
2. Tor installed in your system or placed in the project folder

For system-wide Tor installation:
- **Linux**: `sudo apt install tor` (Debian/Ubuntu) or equivalent for your distribution
- **Windows**: Download from [Tor Project website](https://www.torproject.org/download/tor/)

You can place the Tor executable directly in the project folder:
- **Linux**: Name it `tor`
- **Windows**: Name it `tor.exe`

### Automatic Installation

#### Linux

1. Make the installation script executable:
   ```bash
   chmod +x install.sh
   ```

2. Run the installation script:
   ```bash
   ./install.sh
   ```

3. Follow the prompts to complete installation

#### Windows

1. Run PowerShell as Administrator

2. Execute the installation script:
   ```powershell
   .\install.ps1
   ```

3. Follow the prompts to complete installation

### Manual Installation

If you prefer manual installation:

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Run directly:
   ```bash
   python tordrop.py /path/to/your/file.zip
   ```

---

## Usage

### Basic File Sharing

```

python tordrop.py /path/to/your/file.zip

```

### Advanced Options

```

# One-time download

python tordrop.py --once /path/to/your/file.zip

# 1-hour expiration

python tordrop.py --ttl 3600 /path/to/your/file.zip

# Development mode (without Tor)

python tordrop.py run

```

### Command Line Options

| Option | Description | Default |
|--------|-------------|---------|
| `--ttl <seconds>` | Time-to-live (0 = forever) | `0` |
| `--once` | One-time download | `False` |
| `--simple` | Simplified HTML template | `False` |
| `--port <port>` | Local port | `8080` |
| `--tor-path <path>` | Tor executable path | `tor` |
| `--no-qr` | Disable QR code | `False` |
| `--debug` | Enable debug output | `False` |

---

## How It Works

1. Starts a Tor process on your machine  
2. Creates an ephemeral hidden service  
3. Forwards the service to a local Flask web server  
4. Generates a shareable `.onion` link  
5. Recipients access the file via Tor Browser  

---

## License

This project is licensed under the **GNU GPL v3.0** – see the [LICENSE](LICENSE) file for details.
