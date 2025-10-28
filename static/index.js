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
      this.term.onData(function (data) {
        // console.log(data);
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

labs = new Array();
lab1 = new Meshell("terminal-lab1");
lab2 = new Meshell("terminal-lab2");
lab3 = new Meshell("terminal-lab3");
lab4 = new Meshell("terminal-lab4");

labs.push(lab1);
labs.push(lab2);
labs.push(lab3);
labs.push(lab4);

labs.forEach((lab) => {
  lab.initXterm();
  lab.openConnection();
});
