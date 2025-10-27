function showTerminal(n) {
  const ids = new Array("lab1", "lab2");
  const selected = "lab" + n;

  ids.forEach((id) => {
    curr = document.getElementById(id);
    if (id === selected) {
      curr.style.display = "block";
    } else {
      curr.style.display = "none";
    }
  });
}

// --- Inizializza terminale ---
const term = new Terminal({
  cursorBlink: true,
  fontSize: 14,
  fontFamily: "monospace",
  theme: { background: "#181C25", foreground: "#FFFFFF" },
});
term.open(document.getElementById("terminal-lab1"));
term.writeln('Premi "Apri connessione" per iniziare...');

let ws = null;

function openConnection() {
  if (ws) {
    term.writeln("\r\n⚠️ Connessione già aperta.");
    return;
  }

  ws = new WebSocket("ws://localhost:8080/tty");

  ws.binaryType = "arraybuffer";

  ws.onopen = function () {
    term.writeln("\r\n🔌 Connessione aperta.");
    term.focus();

    // Invia ogni input dell’utente direttamente al server
    term.onData(function (data) {
      console.log(data);
      if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(data);
      }
    });
  };

  ws.onmessage = function (event) {
    // Scrive tutto ciò che arriva dal server nel terminale
    term.write(event.data);
  };

  ws.onerror = function () {
    term.writeln("\r\n❌ Errore WebSocket.");
  };

  ws.onclose = function () {
    term.writeln("\r\n🔒 Connessione chiusa.");
    ws = null;
  };
}

function closeConnection() {
  if (ws) {
    ws.close();
    ws = null;
  } else {
    term.writeln("\r\n⚠️ Nessuna connessione aperta.");
  }
}

document.getElementById("open").onclick = openConnection;
document.getElementById("close").onclick = closeConnection;

// Mantieni focus sul terminale se clicchi dentro
term.element.addEventListener("click", () => term.focus());
