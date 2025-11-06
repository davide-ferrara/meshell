import "@picocss/pico/css/pico.min.css";
import "xterm/css/xterm.css";
import { Terminal } from "xterm";
import { FitAddon } from "xterm-addon-fit";

let labs;

class Meshell {
  constructor(tname) {
    console.log(`New Meshell created for ${tname}`);
    this.tname = tname;
    this.tabId = this.tname + "-tab";
    this.tab = null;
    this.ws = null;
    this.term = null;
    this.fitAddon = new FitAddon();

    this.term = new Terminal({
      cursorBlink: true,
      fontSize: 18,
      fontFamily: "monospace",
      theme: {
        background: "#181C25",
        foreground: "#FFFFFF",
        cursor: "#FFFFFF",
      },
    });
    this.term.open(document.getElementById(this.tname));
    this.term.loadAddon(this.fitAddon);

    this.tab = document.getElementById(this.tabId);
    this.tab.onclick = () => tabsHandler(this.tabId);

    this.term.onResize((size) => {
      const { cols, rows } = size;
      console.log(`Terminal resized to ${cols} cols, ${rows} rows`);
      if (this.ws && this.ws.readyState === WebSocket.OPEN) {
        this.ws.send(JSON.stringify({ type: "resize", cols, rows }));
      }
    });

    this.term.writeln(`This is ${this.tname}`);
  }

  openConnection() {
    if (this.ws) {
      this.term.writeln("\r\nConnection already open.");
      return;
    }

    this.fitAddon.fit();
    const rows = this.term.rows;
    const cols = this.term.cols;
    const socketURL = `ws://${location.host}/tty?rows=${rows}&cols=${cols}`;

    console.log(`Opening WebSocket to: ${socketURL}`);
    this.ws = new WebSocket(socketURL);

    this.ws.binaryType = "arraybuffer";

    this.ws.onopen = () => {
      console.log("WebSocket connection established.");
      this.term.writeln("\r\nWebSocket open.");
      this.term.focus();

      this.term.onData((data) => {
        if (this.ws && this.ws.readyState === WebSocket.OPEN) {
          this.ws.send(data);
        }
      });
    };

    this.ws.onmessage = (event) => {
      this.term.write(new Uint8Array(event.data));
    };

    this.ws.onerror = (event) => {
      console.error("WebSocket error:", event);
      this.term.writeln("\r\nWebSocket error.");
    };

    this.ws.onclose = () => {
      console.log("WebSocket connection closed.");
      this.term.writeln("\r\nConnection closed.");
      this.ws = null;
    };
  }

  closeConnection() {
    if (this.ws) {
      console.log("Closing WebSocket connection.");
      this.ws.close();
      this.ws = null;
    } else {
      this.term.writeln("\r\nNo open connection.");
    }
  }

  sendCommand(command) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      console.log(`Sending command: ${command}`);
      this.ws.send(command + "\n");
    } else {
      this.term.writeln("\r\nNo open connection.");
    }
  }
}

function tabsHandler(tabId) {
  console.log(`Switching to tab: ${tabId}`);
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
  const blacklist = ["clear-terminal", "font-size-decrease", "font-size-increase"];
  const commandButtons = document.querySelectorAll(".button-panel > button");

  commandButtons.forEach((button) => {
    button.addEventListener("click", () => {
      const command = button.id;
      console.log(`Button clicked: ${command}`);

      if (!blacklist.includes(command)) {
        const activeTerminal = getActiveTerminal();
        if (activeTerminal) {
          activeTerminal.sendCommand(`source meshell --cmd ${command}`);
          scrollToTop();
        }
      }
    });
  });
}

function main() {
  console.log("Initializing main function.");

  labs = [];
  const lab1 = new Meshell("terminal-lab1");
  const lab2 = new Meshell("terminal-lab2");

  labs.push(lab1, lab2);

  labs.forEach((lab) => {
    lab.openConnection();
  });

  setupCommandButtons();

  window.addEventListener("resize", () => {
    const activeTerminal = getActiveTerminal();
    if (activeTerminal) {
      console.log("Window resized, fitting active terminal.");
      activeTerminal.fitAddon.fit();
    }
  });

  document
    .getElementById("font-size-increase")
    .addEventListener("click", () => {
      const activeTerminal = getActiveTerminal();
      if (activeTerminal) {
        activeTerminal.term.options.fontSize += 2;
      }
    });

  document
    .getElementById("font-size-decrease")
    .addEventListener("click", () => {
      const activeTerminal = getActiveTerminal();
      if (activeTerminal) {
        activeTerminal.term.options.fontSize -= 2;
      }
    });

  document.getElementById("clear-terminal").addEventListener("click", () => {
    const activeTerminal = getActiveTerminal();
    if (activeTerminal) {
      activeTerminal.term.clear();
    }
  });
}

main();