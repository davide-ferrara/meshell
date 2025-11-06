package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"sync"

	// "text/template"

	"github.com/gorilla/websocket"
	"golang.org/x/crypto/ssh"
	"golang.org/x/crypto/ssh/knownhosts"
)

type Client struct {
	username string
	password string
	addr     string
}

// --- Variabili globali ---

var (
	// indexHTML    = loadPage("./static/index.html") // index.html deve esistere nella directory
	// homeTemplate = template.Must(template.New("").Parse(indexHTML))
	upgrader = websocket.Upgrader{} // Impostazioni predefinite
	addr     = flag.String("addr", "localhost:8080", "HTTP service address")
	clients  = []Client{
		{username: "lab1", password: "lab1", addr: "localhost:9090"},
		{username: "lab2", password: "lab2", addr: "localhost:9091"},
	}
)

// --- Funzioni di Utility ---

// func loadPage(filename string) string {
// 	data, err := os.ReadFile(filename)
// 	if err != nil {
// 		panic(err)
// 	}
// 	return string(data)
// }

func connectSSH(user string, password string, addr string) (*ssh.Client, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return nil, fmt.Errorf("could not get home dir: %w", err)
	}

	khPath := filepath.Join(home, ".ssh", "known_hosts")
	log.Printf("SSH Known Host file found at: %v", khPath)

	hostKeyCallback, err := knownhosts.New(khPath)
	if err != nil {
		log.Printf("Warning: Failed to load known_hosts: %v. Using InsecureIgnoreHostKey.", err)
		hostKeyCallback = ssh.InsecureIgnoreHostKey()
	}

	config := &ssh.ClientConfig{
		User: user,
		Auth: []ssh.AuthMethod{
			ssh.Password(password),
		},
		HostKeyCallback: hostKeyCallback,
	}

	return ssh.Dial("tcp", addr, config)
}

// --- Creazione della sessione SSH con pipe pre-Shell() ---

func setupSSHSession(client *ssh.Client) (*ssh.Session, io.WriteCloser, io.Reader, io.Reader, error) {
	session, err := client.NewSession()
	if err != nil {
		return nil, nil, nil, nil, fmt.Errorf("failed to create session: %w", err)
	}

	// --- Pipes PRIMA della shell ---
	sshStdin, err := session.StdinPipe()
	if err != nil {
		session.Close()
		return nil, nil, nil, nil, fmt.Errorf("failed to get stdin pipe: %w", err)
	}

	sshStdout, err := session.StdoutPipe()
	if err != nil {
		session.Close()
		return nil, nil, nil, nil, fmt.Errorf("failed to get stdout pipe: %w", err)
	}

	sshStderr, err := session.StderrPipe()
	if err != nil {
		session.Close()
		return nil, nil, nil, nil, fmt.Errorf("failed to get stderr pipe: %w", err)
	}

	modes := ssh.TerminalModes{
		ssh.ECHO:          1,
		ssh.TTY_OP_ISPEED: 14400,
		ssh.TTY_OP_OSPEED: 14400,
	}

	if err := session.RequestPty("xterm", 80, 40, modes); err != nil {
		session.Close()
		return nil, nil, nil, nil, fmt.Errorf("request pty failed: %w", err)
	}

	// Solo dopo avere ottenuto le pipe:
	if err := session.Shell(); err != nil {
		session.Close()
		return nil, nil, nil, nil, fmt.Errorf("start shell failed: %w", err)
	}

	return session, sshStdin, sshStdout, sshStderr, nil
}

// --- Implementazione Writer per WebSocket ---

type websocketWriter struct {
	ws *websocket.Conn
}

func (w *websocketWriter) Write(p []byte) (n int, err error) {
	err = w.ws.WriteMessage(websocket.BinaryMessage, p)
	if err != nil {
		return 0, err
	}
	return len(p), nil
}

// --- Funzioni di copia tra stream ---

func copyStream(dst io.Writer, src io.Reader) {
	if _, err := io.Copy(dst, src); err != nil {
		if err != io.EOF && !websocket.IsCloseError(err, websocket.CloseGoingAway) {
			log.Println("Stream copy error:", err)
		}
	}
}

// --- Gestione piping WebSocket <-> SSH ---

func startPiping(ws *websocket.Conn, sshStdin io.WriteCloser, sshStdout, sshStderr io.Reader, sshSession *ssh.Session) error {
	var wg sync.WaitGroup
	wg.Add(3)

	// 1. Input dal client WebSocket -> SSH stdin
	go func() {
		defer wg.Done()
		defer sshStdin.Close()
		for {
			_, p, err := ws.ReadMessage()
			if err != nil {
				log.Println("WebSocket input stream closed/error:", err)
				return
			}

			var msg map[string]interface{}
			if err := json.Unmarshal(p, &msg); err == nil && msg["type"] == "resize" {
				cols := int(msg["cols"].(float64))
				rows := int(msg["rows"].(float64))
				if err := sshSession.WindowChange(rows, cols); err != nil {
					log.Println("SSH window change error:", err)
				}
				continue
			}
			if _, err := sshStdin.Write(p); err != nil {
				log.Println("SSH Stdin write error:", err)
				return
			}
		}
	}()

	// 2. Output SSH stdout -> WebSocket
	writer := &websocketWriter{ws: ws}
	go func() { defer wg.Done(); copyStream(writer, sshStdout) }()

	// 3. Output SSH stderr -> WebSocket
	go func() { defer wg.Done(); copyStream(writer, sshStderr) }()

	// 4. Attendere la chiusura della sessione remota
	err := sshSession.Wait()
	wg.Wait()
	return err
}

// --- Handler HTTP ---

func tty(w http.ResponseWriter, r *http.Request) {
	ws, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("HTTP could not be upgraded to WS:", err)
		return
	}
	log.Println("HTTP upgraded to WS")
	defer ws.Close()

	// Connessione SSH
	// sshClient, err := connectSSH("lab1", "lab1", "localhost:9090")
	for _, client := range clients {
		sshClient, err := connectSSH(client.username, client.password, client.addr)
		if err != nil {
			log.Println("SSH connection failed:", err)
			ws.WriteMessage(websocket.TextMessage, []byte("SSH connection error"))
			return
		}
		defer sshClient.Close()

		sshSession, sshStdin, sshStdout, sshStderr, err := setupSSHSession(sshClient)
		if err != nil {
			log.Println("SSH session setup failed:", err)
			ws.WriteMessage(websocket.TextMessage, []byte("SSH session setup failed"))
			return
		}
		defer sshSession.Close()

		if err := startPiping(ws, sshStdin, sshStdout, sshStderr, sshSession); err != nil {
			log.Println("Piping error:", err)
		}

		log.Println("Sessione chiusa.")
	}
}

//	func home(w http.ResponseWriter, r *http.Request) {
//		if err := homeTemplate.Execute(w, "ws://"+r.Host+"/tty"); err != nil {
//			log.Println("Error executing template:", err)
//		}
//	}
func home(w http.ResponseWriter, r *http.Request) {
	// Se il percorso non è esattamente "/", lascia che sia gestito
	// dal FileServer (o restituisci 404 se preferisci).
	// In questo caso, gestiamo solo la root.
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	http.ServeFile(w, r, "index.html")
}

func main() {
	flag.Parse()
	log.SetFlags(log.Ldate | log.Ltime)

	// if indexHTML == "" {
	// 	log.Fatalf("Errore: index.html non caricato.")
	// }

	log.Printf("Meshell Server is starting...")
	log.Printf("Server listening on address %s", *addr)

	http.HandleFunc("/tty", tty)
	http.HandleFunc("/", home)
	http.Handle("/node_modules/", http.StripPrefix("/node_modules/", http.FileServer(http.Dir("node_modules"))))
	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	err := http.ListenAndServe(*addr, nil)
	if err != nil {
		log.Fatalf("Errore durante l'avvio del server: %v", err)
	}
}
