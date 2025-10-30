<p align="center">
  <img src="static/logo.png" alt="Meshell Logo" width="200"/>
</p>

<h1 align="center">Meshell</h1>

<p align="center">
  <img src="https://img.shields.io/github/license/meshell-dev/meshell" alt="License"/>
  <img src="https://img.shields.io/github/last-commit/meshell-dev/meshell" alt="Last commit"/>
  <img src="https://img.shields.io/github/issues/meshell-dev/meshell" alt="Issues"/>
  <img src="https://img.shields.io/github/forks/meshell-dev/meshell" alt="Forks"/>
  <img src="https://img.shields.io/github/stars/meshell-dev/meshell" alt="Stars"/>
</p>

<p align="center">
  <strong>A versatile and powerful tool for managing remote machines and executing commands.</strong>
</p>

<p align="center">
  <a href="#about-meshell">About</a> •
  <a href="#features">Features</a> •
  <a href="#gallery">Gallery</a> •
  <a href="#technologies-used">Technologies</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#usage">Usage</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#license">License</a>
</p>

---

## Table of Contents

*   [About Meshell](#about-meshell)
*   [Features](#features)
*   [Gallery](#gallery)
*   [Technologies Used](#technologies-used)
*   [Getting Started](#getting-started)
*   [Usage](#usage)
*   [Building the project](#building-the-project)
*   [Running the project as a service](#running-the-project-as-a-service)
*   [Installation and Uninstallation Scripts](#installation-and-uninstallation-scripts)
*   [Using Meshell with Docker](#using-meshell-with-docker)
*   [Project Structure](#project-structure)
*   [Roadmap](#roadmap)
*   [Contributing](#contributing)
*   [Support](#support)
*   [Acknowledgments](#acknowledgments)
*   [License](#license)
*   [Changelog](#changelog)

---

## About Meshell

Meshell is a comprehensive solution for developers and system administrators who need to manage multiple remote machines efficiently. It provides both a web-based SSH terminal and a powerful command-line interface (CLI) to streamline your workflow.

The project consists of two main components:

*   **Web-based SSH Terminal**: A Go-based web server that provides a beautiful and intuitive web interface for accessing remote machines via SSH. It uses WebSockets for real-time communication and `xterm.js` for a fully-featured terminal experience in your browser.
*   **Command-Line Interface (CLI)**: A feature-rich Bash script (`meshell.sh`) that offers a wide range of commands for managing virtual machines, interacting with the system, and performing various administrative tasks.

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## Features

### Web-based SSH Terminal

*   **Multi-Tab Interface**: Easily switch between multiple remote sessions with a clean and intuitive tabbed interface.
*   **Predefined Command Buttons**: Execute common commands with a single click using the predefined command buttons, categorized for ease of use (System, File System, Network, Shell).
*   **Real-time Interaction**: Experience a smooth and responsive terminal session thanks to the use of WebSockets.
*   **Modern UI**: A clean and modern user interface built with Pico.css.

### Command-Line Interface (`meshell.sh`)

*   **VM Management**: Start, stop, and list VirtualBox virtual machines.
*   **Interactive Commands**: An extensive set of interactive commands for system administration, including:
    *   **System**: `uptime`, `free`, `ps`, `top`, `kill`, `shutdown`, `reboot`, etc.
    *   **Package Management**: `apt update`, `apt install`, `apt search`, `apt remove`.
    *   **File System**: `ls`, `mkdir`, `tree`, `ln`, `chmod`, `chown`, etc.
    *   **Network**: `ping`, `wget`, `curl`, `ip`, `netcat`, `dig`, `host`, `nslookup`, etc.
    *   **User & Group Management**: `useradd`, `userdel`, `groupadd`, `groupdel`, `usermod`.
    *   **System Information**: `uname`, `du`, `vm_stat`, `ifconfig`, `netstat`, `route`, `arp`, `lshw`, `lsblk`, `lspci`, `lsusb`, `lsmod`, `dmesg`, `journalctl`, `systemctl`.
*   **Italian Language Support**: All interactive prompts and messages are in Italian.
*   **Extensible**: Easily add new commands to the script.

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## Gallery

<p align="center">
  <img src="static/logo.png" alt="Meshell Screenshot 1" width="400"/>
  <img src="static/logo.png" alt="Meshell Screenshot 2" width="400"/>
</p>

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## Technologies Used

*   **Go**: The backend web server is written in Go.
*   **WebSockets**: Used for real-time communication between the web interface and the server.
*   **xterm.js**: A JavaScript library for creating a terminal in the browser.
*   **Pico.css**: A lightweight CSS framework for styling the web interface.
*   **Bash**: The command-line interface is a Bash script.
*   **Docker**: Used for containerizing the application.

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## Getting Started

### Prerequisites

*   [Go](https://golang.org/doc/install)
*   [Node.js and npm](https://nodejs.org/en/download/)
*   [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (for VM management)
*   A modern web browser

### Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/meshell-dev/meshell.git
    cd meshell
    ```

2.  **Install Go dependencies:**

    ```bash
    go mod tidy
    ```

3.  **Install npm dependencies:**

    ```bash
    npm install
    ```

4.  **Make the `meshell.sh` script executable:**

    ```bash
    chmod +x meshell.sh
    ```

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## Usage

### Web-based SSH Terminal

1.  **Start the web server:**

    ```bash
    npm start
    ```

2.  **Open your web browser and navigate to `http://localhost:8080`.**

You will see the Meshell web interface with tabs for each configured remote machine. Click on a tab to open an SSH session to that machine.

### Command-Line Interface (`meshell.sh`)

The `meshell.sh` script provides a wide range of commands. To see the available commands, run:

```bash
./meshell.sh --h
```

To execute a specific command, use the `--cmd` flag. For example, to see the system's uptime:

```bash
./meshell.sh --cmd uptime
```

Many commands are interactive and will prompt you for input in Italian.

### Adding a new command to `meshell.sh`

To add a new command to the `meshell.sh` script, you need to edit the `meshell.sh` file and add a new case to the `case $2 in` block.

For example, to add a new command called `mycommand`, you would add the following code to the `case` block:

```bash
    "mycommand")
        echo "Eseguendo 'mycommand': Questo è un nuovo comando."
        # Add your command here
        ;; 
```

### Adding a new button to the web interface

To add a new button to the web interface, you need to edit the `index.html` file and add a new button to one of the `div` elements with the class `button-panel`.

For example, to add a new button to the `System` section, you would add the following code to the `div` element with the id `system-cmd`:

```html
<button class="secondary" id="mycommand">My Command</button>
```

Then, you need to edit the `static/index.js` file to add an event listener for the new button. For example:

```javascript
document.getElementById('mycommand').addEventListener('click', () => {
    term.write('mycommand\n');
});
```

### Configuring the SSH clients

To configure the SSH clients that the web interface can connect to, you need to edit the `server.go` file and modify the `clients` slice.

For example, to add a new SSH client, you would add a new `Client` struct to the `clients` slice:

```go
clients  = []Client{
    {username: "lab1", password: "lab1", addr: "localhost:9090"},
    {username: "lab2", password: "lab2", addr: "localhost:9091"},
    {username: "newclient", password: "newpassword", addr: "newhost:22"},
}
```

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## Building the project

To build the project, you can use the `go build` command:

```bash
go build -o meshell_server server.go
```

This will create a binary executable file named `meshell_server` in the current directory.

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## Running the project as a service

To run the project as a service, you can create a systemd service file.

1.  **Create a new service file:**

    ```bash
    sudo nano /etc/systemd/system/meshell.service
    ```

2.  **Add the following content to the file:**

    ```ini
    [Unit]
    Description=Meshell Web SSH Terminal
    After=network.target

    [Service]
    User=your-user
    Group=your-group
    WorkingDirectory=/path/to/meshell
    ExecStart=/path/to/meshell/meshell_server
    Restart=always

    [Install]
    WantedBy=multi-user.target
    ```

    Replace `your-user`, `your-group`, and `/path/to/meshell` with your actual user, group, and project path.

3.  **Reload the systemd daemon:**

    ```bash
    sudo systemctl daemon-reload
    ```

4.  **Start the service:**

    ```bash
    sudo systemctl start meshell.service
    ```

5.  **Enable the service to start on boot:**

    ```bash
    sudo systemctl enable meshell.service
    ```

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## Installation and Uninstallation Scripts

The project includes `install.sh` and `uninstall.sh` scripts to simplify the installation and uninstallation process.

### `install.sh`

The `install.sh` script automates the following steps:

*   Builds the Go project.
*   Creates the systemd service file.
*   Reloads the systemd daemon.
*   Starts and enables the `meshell` service.

To use the script, run:

```bash
sudo ./install.sh
```

### `uninstall.sh`

The `uninstall.sh` script automates the following steps:

*   Stops and disables the `meshell` service.
*   Removes the systemd service file.
*   Reloads the systemd daemon.
*   Removes the built binary.

To use the script, run:

```bash
sudo ./uninstall.sh
```

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## Using Meshell with Docker

You can also run the Meshell web interface in a Docker container.

1.  **Build the Docker image:**

    ```bash
    docker build -t meshell .
    ```

2.  **Run the Docker container:**

    ```bash
    docker run -p 8080:8080 meshell
    ```

3.  **Open your web browser and navigate to `http://localhost:8080`.**

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## Project Structure

```
.
├── .dockerignore
├── .gitignore
├── Dockerfile
├── LICENSE
├── README.md
├── cmds.txt
├── go.mod
├── go.sum
├── index.html
├── install.sh
├── meshell.sh
├── server.go
├── static
│   ├── favicon
│   │   ├── apple-touch-icon.png
│   │   ├── favicon-96x96.png
│   │   ├── favicon.ico
│   │   ├── favicon.svg
│   │   ├── site.webmanifest
│   │   ├── web-app-manifest-192x192.png
│   │   └── web-app-manifest-512x512.png
│   ├── index.js
│   ├── logo.png
│   └── style.css
└── uninstall.sh
```

### File Descriptions

*   **`.dockerignore`**: Specifies the files and directories to exclude from the Docker build context.
*   **`.gitignore`**: Specifies the files and directories to be ignored by Git.
*   **`Dockerfile`**: Contains the instructions for building the Docker image.
*   **`LICENSE`**: The license for the project.
*   **`README.md`**: This file.
*   **`cmds.txt`**: A list of commands that can be executed by the `meshell.sh` script.
*   **`go.mod`**: The Go module file.
*   **`go.sum`**: The Go module checksum file.
*   **`index.html`**: The main HTML file for the web interface.
*   **`install.sh`**: A script to automate the installation of the project.
*   **`meshell.sh`**: The main command-line interface script.
*   **`server.go`**: The Go web server.
*   **`static`**: A directory containing the static assets for the web interface (CSS, JavaScript, images).
*   **`uninstall.sh`**: A script to automate the uninstallation of the project.

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## Roadmap

*   [ ] Add support for more SSH clients.
*   [ ] Add support for customizing the web interface.
*   [ ] Add support for more commands in the `meshell.sh` script.
*   [ ] Add support for internationalization.

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## Contributing

Contributions are welcome! If you have any ideas, suggestions, or bug reports, please open an issue or submit a pull request.

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## Support

If you have any questions or need support, please open an issue on the [GitHub issues page](https://github.com/meshell-dev/meshell/issues).

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## Acknowledgments

*   [xterm.js](https://xtermjs.org/)
*   [Pico.css](https://picocss.com/)
*   [Gorilla WebSocket](https://github.com/gorilla/websocket)
*   [Go](https://golang.org/)

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

<p align="right">(<a href="#table-of-contents">back to top</a>)</p>

## Changelog


### v1.0.0 (2025-10-28)


*   Initial release.


<p align="right">(<a href="#table-of-contents">back to top</a>)</p>



## Contributors







*   **[meshell-dev](https://github.com/meshell-dev)** - creator and maintainer







<p align="right">(<a href="#table-of-contents">back to top</a>)</p>







## Code of Conduct







Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms.







<p align="right">(<a href="#table-of-contents">back to top</a>)</p>


