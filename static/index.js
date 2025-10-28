class Meshell {
  constructor(tname) {
    this.tname = tname;
    this.tabId = this.tname + "-tab";
    this.tab = null;
    this.ws = null;
    this.term = null;
  }

  initXterm() {
    this.term = new Terminal({
      cursorBlink: true,
      fontSize: 14,
      fontFamily: "monospace",
      theme: { background: "#181C25", foreground: "#FFFFFF" },
    });
    this.term.open(document.getElementById(this.tname));
    this.term.writeln(`This is ${this.tname}`);

    this.tab = document.getElementById(this.tabId);
    this.tab.onclick = () => tabsHandler(this.tabId);
  }

  openConnection() {
    if (this.ws) {
      this.term.writeln("\r\nConnessione già aperta.");
      return;
    }

    this.ws = new WebSocket("ws://localhost:8080/tty");

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
      this.term.write(event.data);
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

const labs = new Array();
const lab1 = new Meshell("terminal-lab1");
const lab2 = new Meshell("terminal-lab2");
const lab3 = new Meshell("terminal-lab3");
const lab4 = new Meshell("terminal-lab4");

labs.push(lab1);
labs.push(lab2);
labs.push(lab3);
labs.push(lab4);

labs.forEach((lab) => {
  lab.initXterm();
  lab.openConnection();
});

const commandButtons = document.querySelectorAll(".button-panel > button");

commandButtons.forEach((button) => {
  button.addEventListener("click", () => {
    const command = button.id;
    const activeTerminal = getActiveTerminal();
    if (activeTerminal) {
      activeTerminal.sendCommand(`meshell --cmd ${command}`);
    }

    const newLab = new Meshell(newLabId);
    labs.push(newLab);
    newLab.initXterm();
    newLab.openConnection();
    tabsHandler(newTabId);
  });
});

// document.getElementById("scroll-top").addEventListener("click", () => {
//     const activeTerminal = getActiveTerminal();
//     if (activeTerminal) {
//         activeTerminal.term.scrollToTop();
//     }
// });
//
// document.getElementById("scroll-bottom").addEventListener("click", () => {
//     const activeTerminal = getActiveTerminal();
//     if (activeTerminal) {
//         activeTerminal.term.scrollToBottom();
//     }
// });
//
// let searchTerm = "";
//
// document.getElementById("search").addEventListener("click", () => {
//     const activeTerminal = getActiveTerminal();
//     if (activeTerminal) {
//         searchTerm = prompt("Enter search term:");
//         if (searchTerm) {
//             activeTerminal.term.loadAddon(new SearchAddon());
//             activeTerminal.term.findNext(searchTerm);
//         }
//     }
// });
//
// document.getElementById("find-previous").addEventListener("click", () => {
//     const activeTerminal = getActiveTerminal();
//     if (activeTerminal && searchTerm) {
//         activeTerminal.term.findPrevious(searchTerm);
//     }
// });
//
// document.getElementById("find-next").addEventListener("click", () => {
//     const activeTerminal = getActiveTerminal();
//     if (activeTerminal && searchTerm) {
//         activeTerminal.term.findNext(searchTerm);
//     }
// });
//
// document.getElementById("clear-search").addEventListener("click", () => {
//     const activeTerminal = getActiveTerminal();
//     if (activeTerminal) {
//         activeTerminal.term.clearSearch();
//         searchTerm = "";
//     }
// });
//
// document.getElementById("fullscreen").addEventListener("click", () => {
//     const activeTerminal = getActiveTerminal();
//     if (activeTerminal) {
//         activeTerminal.term.toggleFullScreen();
//     }
// });
//
// document.getElementById("search").addEventListener("click", () => {
//     const activeTerminal = getActiveTerminal();
//     if (activeTerminal) {
//         const searchTerm = prompt("Enter search term:");
//         if (searchTerm) {
//             activeTerminal.term.loadAddon(new SearchAddon());
//             activeTerminal.term.findNext(searchTerm);
//         }
//     }
// });
//
//             document.querySelectorAll(".advanced").forEach((button) => {
//                 button.style.display = "none";
//             });
//
//             document.getElementById("clear-terminal").addEventListener("click", () => {
//
//             const activeTerminal = getActiveTerminal();
//                 if (activeTerminal) {
//                     activeTerminal.term.clear();
//                 }
//             });
//
//             const themes = [
//                 { background: "#181C25", foreground: "#FFFFFF" },
//                 { background: "#FFFFFF", foreground: "#000000" },
//                 { background: "#000000", foreground: "#00FF00" },
//             ];
//
//             let currentTheme = 0;
//
//             document.getElementById("switch-theme").addEventListener("click", () => {
//                 currentTheme = (currentTheme + 1) % themes.length;
//                 const activeTerminal = getActiveTerminal();
//                     if (activeTerminal) {
//                         activeTerminal.term.setOption("theme", themes[currentTheme]);
//                     }
//                 });
//
//                 document.getElementById("font-size-decrease").addEventListener("click", () => {
//                     const activeTerminal = getActiveTerminal();
//                     if (activeTerminal) {
//                         const newSize = activeTerminal.term.getOption("fontSize") - 1;
//                         activeTerminal.term.setOption("fontSize", newSize);
//                     }
//                 });
//
//                 document.getElementById("font-size-increase").addEventListener("click", () => {
//                     const activeTerminal = getActiveTerminal();
//                         if (activeTerminal) {
//                             const newSize = activeTerminal.term.getOption("fontSize") + 1;
//                             activeTerminal.term.setOption("fontSize", newSize);
//                         }
//                     });
//
//                     document.getElementById("focus-terminal").addEventListener("click", () => {
//                         const activeTerminal = getActiveTerminal();
//                             if (activeTerminal) {
//                                 activeTerminal.term.focus();
//                             }
//                         });
//
//                         document.getElementById("toggle-advanced").addEventListener("click", () => {
//                             const advancedButtons = document.querySelectorAll(".advanced");
//                             advancedButtons.forEach((button) => {
//                                 button.style.display = button.style.display === "none" ? "" : "none";
//                             });
//                         });
