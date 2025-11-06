# Meshell

<p align="center">
  <img src="static/logo.png" alt="Meshell Logo" width="200"/>
</p>

<p align="center">
  <strong>A versatile and powerful tool for managing remote machines and executing commands via a web-based SSH terminal.</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#gallery">Gallery</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#commands">Commands</a> •
  <a href="#license">License</a>
</p>

---

## Features

*   **Web-based SSH Terminal**: A Go-based web server providing a beautiful and intuitive web interface for accessing remote machines via SSH.
*   **Multi-Tab Interface**: Easily switch between multiple remote sessions.
*   **Predefined Command Buttons**: Execute common commands with a single click, categorized for ease of use.
*   **Modern UI**: A clean and modern user interface built with Pico.css and Vite.

## Gallery

<p align="center">
  <img src="docs/gallery1.png" alt="Meshell Screenshot" width="800"/>
</p>

## Getting Started

### Prerequisites

*   [Go](https://golang.org/doc/install)
*   [Node.js and npm](https://nodejs.org/en/download/)

### Installation & Running

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/davide-ferrara/meshell.git
    cd meshell
    ```

2.  **Install dependencies:**
    ```bash
    go mod tidy
    npm install
    ```

3.  **Start the web server:**
    ```bash
    npm start
    ```

4.  **Open your web browser and navigate to `http://localhost:8080`.**

## Commands

The Meshell web interface provides buttons for the following commands, grouped by category.

*   **General:** `ls`, `cd`, `cdback`, `cdhome`, `cdroot`, `pwd`, `sudash`, `meshell-update`
*   **Package Management:** `update`, `install`, `search`, `remove`
*   **System:** `top`, `ps`, `searchps`, `kill`, `uname`, `uptime`, `free`, `du`, `w`, `last`, `date`, `cal`, `shutdown`, `reboot`
*   **File System:** `inode`, `mkdir`, `touch`, `tree`, `ln`, `umask`, `chmod`, `chown`, `find`, `file`
*   **User Management:** `showusers`, `showgroups`, `groups`, `useradd`, `groupadd`, `user-add-to-group`, `userdel`, `groupdel`, `user-remove-to-group`, `passwd`, `whoami`, `id`
*   **Network:** `ping`, `wget`, `curl`, `ip`, `ifconfig`, `dig`, `host`, `hosts-edit`, `netstat`, `route`, `arp`
*   **Shell:** `history`, `which`, `type`, `alias`, `alias-remove`, `prompt`, `path`, `bashrc`
*   **Hardware:** `lshw`, `lsblk`, `lspci`, `lsusb`
*   **Kernel:** `lsmod`, `dmesg`, `journalctl`

## License

This project is licensed under the GNU GPLv3 - see the [LICENSE](LICENSE) file for details.