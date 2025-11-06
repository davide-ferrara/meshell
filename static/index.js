import "@picocss/pico/css/pico.min.css";
import "xterm/css/xterm.css";
import { Terminal, XtermOptions } from "xterm";
import { FitAddon } from "xterm-addon-fit";

let labs;

class Meshell {
  constructor(tname) {
    this.tname = tname;
    this.tabId = this.tname + "-tab";
    this.tab = null;
    this.ws = null;
    this.term = null;
    this.fitAddon = new FitAddon();

    this.term = new Terminal();
    this.term.options = {
      cursorBlink: true,
      fontSize: 18,
      fontFamily: "monospace",
      theme: { background: "#181C25", foreground: "#FFFFFF" },
    };
    this.term.open(document.getElementById(this.tname));
    this.term.loadAddon(this.fitAddon);

    this.tab = document.getElementById(this.tabId);
    this.tab.onclick = () => tabsHandler(this.tabId);

    this.term.onResize((size) => {
      const { cols, rows } = size;
      if (this.ws && this.ws.readyState === WebSocket.OPEN) {
        this.ws.send(JSON.stringify({ type: "resize", cols, rows }));
      }
    });

    this.term.writeln(`This is ${this.tname}`);
  }

  openConnection() {
    if (this.ws) {
      this.term.writeln("\r\nConnessione già aperta.");
      return;
    }

    this.ws = new WebSocket(`ws://${location.host}/tty`);

    this.ws.binaryType = "arraybuffer";

    this.ws.onopen = () => {
      this.term.writeln("\r\nWebsocket aperto.");
      this.term.focus();

      // Invia ogni input dell’utente direttamente al server
      this.term.onData((data) => {
        if (this.ws && this.ws.readyState === WebSocket.OPEN) {
          this.ws.send(data);
        }
      });
    };

    this.ws.onmessage = (event) => {
      // Scrive tutto ciò che arriva dal server nel terminale
      this.term.write(new Uint8Array(event.data));
    };

    this.ws.onerror = () => {
      this.term.writeln("\r\nErrore WebSocket.");
    };

    this.ws.onclose = () => {
      this.term.writeln("\r\nConnessione chiusa.");
      this.ws = null;
    };
  }

  closeConnection() {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    } else {
      this.term.writeln("\r\nNessuna connessione aperta.");
    }
  }

  sendCommand(command) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(command + "\n");
    } else {
      this.term.writeln("\r\nNessuna connessione aperta.");
    }
  }
}

function tabsHandler(tabId) {
  const tabs = document.querySelectorAll("#tabs > button");

  tabs.forEach((button) => {
    const container = document.getElementById(
      button.id.replace("tab", "container"),
    );

    if (button.id === tabId) {
      button.ariaCurrent = true;
      container.hidden = false;
      const activeTerminal = getActiveTerminal();
      if (activeTerminal) {
        activeTerminal.fitAddon.fit();
      }
    } else {
      button.ariaCurrent = false;
      container.hidden = true;
    }
  });
}

function getActiveTerminal() {
  const tabs = document.querySelectorAll("#tabs > button");
  for (const button of tabs) {
    if (button.ariaCurrent === "true") {
      const labId = button.id.replace("-tab", "");
      return labs.find((lab) => lab.tname.includes(labId));
    }
  }
  return null;
}

function scrollToTop() {
  window.scrollTo({
    top: 0,
    behavior: "smooth",
  });
}

function setupCommandButtons() {
  const blacklist = new Array();
  blacklist.push("clear-terminal");
  blacklist.push("font-size-decrease");
  blacklist.push("font-size-increase");

  const commandButtons = document.querySelectorAll(".button-panel > button");

  commandButtons.forEach((button) => {
    button.addEventListener("click", () => {
      const command = button.id;

      if (!blacklist.includes(command)) {
        const activeTerminal = getActiveTerminal();
        if (activeTerminal) {
          if (
            button.id === "cd" ||
            button.id === "cdback" ||
            button.id === "cdhome" ||
            button.id === "cdroot" ||
            button.id === "umask"
          ) {
            // Important to use source or the script will be executed in a child process
            activeTerminal.sendCommand(`source meshell --cmd ${command}`);
          }
          activeTerminal.sendCommand(`meshell --cmd ${command}`);
          scrollToTop();
        }
      }
    });
  });
}

function main() {
  console.log("Index.js loaded!");

  labs = new Array();
  const lab1 = new Meshell("terminal-lab1");
  const lab2 = new Meshell("terminal-lab2");
  const lab3 = new Meshell("terminal-lab3");
  const lab4 = new Meshell("terminal-lab4");

  labs.push(lab1);
  labs.push(lab2);
  labs.push(lab3);
  labs.push(lab4);

  labs.forEach((lab) => {
    lab.openConnection();
  });

  setupCommandButtons();

  window.addEventListener("resize", () => {
    const activeTerminal = getActiveTerminal();
    if (activeTerminal) {
      activeTerminal.fitAddon.fit();
    }
  });

  document
    .getElementById("font-size-increase")
    .addEventListener("click", () => {
      let currFontSize;
      const activeTerminal = getActiveTerminal();
      if (activeTerminal) {
        currFontSize = activeTerminal.term.options.fontSize;
        activeTerminal.term.options = { fontSize: currFontSize + 2 };
      }
    });

  document
    .getElementById("font-size-decrease")
    .addEventListener("click", () => {
      let currFontSize;
      const activeTerminal = getActiveTerminal();
      if (activeTerminal) {
        currFontSize = activeTerminal.term.options.fontSize;
        activeTerminal.term.options = { fontSize: currFontSize - 2 };
      }
    });

  document.getElementById("clear-terminal").addEventListener("click", () => {
    let currFontSize;
    const activeTerminal = getActiveTerminal();
    if (activeTerminal) {
      activeTerminal.sendCommand("clear");
      activeTerminal.term.clear();
    }
  });
}

main();
