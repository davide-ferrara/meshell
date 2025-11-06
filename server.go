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
	"strconv"
	"sync"

	"github.com/gorilla/websocket"
	"golang.org/x/crypto/ssh"
	"golang.org/x/crypto/ssh/knownhosts"
)

type Client struct {
	username string
	password string
	addr     string
}

// --- Global Variables ---

var (
	upgrader = websocket.Upgrader{} // Default settings
	addr     = flag.String("addr", "localhost:8080", "HTTP service address")
	clients  = []Client{
		{username: "lab1", password: "lab1", addr: "localhost:9090"},
		{username: "lab2", password: "lab2", addr: "localhost:9091"},
	}
)

// --- Utility Functions ---

func connectSSH(user string, password string, addr string) (*ssh.Client, error) {
	log.Printf("Attempting SSH connection for user %s to %s", user, addr)
	home, err := os.UserHomeDir()
	if err != nil {
		return nil, fmt.Errorf("could not get home dir: %w", err)
	}

	khPath := filepath.Join(home, ".ssh", "known_hosts")
	hostKeyCallback, err := knownhosts.New(khPath)
	if err != nil {
		log.Printf("Warning: Failed to load known_hosts file at %s: %v. Using InsecureIgnoreHostKey.", khPath, err)
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

// --- SSH Session Creation ---

func setupSSHSession(client *ssh.Client, rows int, cols int) (*ssh.Session, io.WriteCloser, io.Reader, io.Reader, error) {
	session, err := client.NewSession()
	if err != nil {
		return nil, nil, nil, nil, fmt.Errorf("failed to create session: %w", err)
	}

	// --- Pipes (must be created before shell) ---
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

	log.Printf("Requesting PTY with size %dx%d", rows, cols)
	if err := session.RequestPty("xterm", rows, cols, modes); err != nil {
		session.Close()
		return nil, nil, nil, nil, fmt.Errorf("request pty failed: %w", err)
	}

	// --- Start Shell (only after getting pipes) ---
	if err := session.Shell(); err != nil {
		session.Close()
		return nil, nil, nil, nil, fmt.Errorf("start shell failed: %w", err)
	}

	return session, sshStdin, sshStdout, sshStderr, nil
}

// --- WebSocket Writer Implementation ---

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

// --- Stream Copying Functions ---

func copyStream(dst io.Writer, src io.Reader) {
	if _, err := io.Copy(dst, src); err != nil {
		if err != io.EOF && !websocket.IsCloseError(err, websocket.CloseGoingAway) {
			log.Printf("Stream copy error: %v", err)
		}
	}
}

// --- WebSocket <-> SSH Piping Management ---

func startPiping(ws *websocket.Conn, sshStdin io.WriteCloser, sshStdout, sshStderr io.Reader, sshSession *ssh.Session) error {
	log.Println("Starting WebSocket <-> SSH piping")
	var wg sync.WaitGroup
	wg.Add(3)

	// 1. WebSocket client input -> SSH stdin
	go func() {
		defer wg.Done()
		defer sshStdin.Close()
		for {
			_, p, err := ws.ReadMessage()
			if err != nil {
				log.Printf("WebSocket input stream closed/error: %v", err)
				return
			}

			var msg map[string]interface{}
			if err := json.Unmarshal(p, &msg); err == nil && msg["type"] == "resize" {
				cols := int(msg["cols"].(float64))
				rows := int(msg["rows"].(float64))
				log.Printf("Received resize event: %dx%d", rows, cols)
				if err := sshSession.WindowChange(rows, cols); err != nil {
					log.Printf("SSH window change error: %v", err)
				}
				continue
			}
			if _, err := sshStdin.Write(p); err != nil {
				log.Printf("SSH Stdin write error: %v", err)
				return
			}
		}
	}()

	// 2. SSH stdout -> WebSocket
	writer := &websocketWriter{ws: ws}
	go func() { defer wg.Done(); copyStream(writer, sshStdout) }()

	// 3. SSH stderr -> WebSocket
	go func() { defer wg.Done(); copyStream(writer, sshStderr) }()

	// 4. Wait for remote session to close
	err := sshSession.Wait()
	wg.Wait()
	log.Println("Piping finished")
	return err
}

// --- HTTP Handlers ---

func tty(w http.ResponseWriter, r *http.Request) {
	log.Printf("Incoming tty request from %s", r.RemoteAddr)

	ws, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("HTTP could not be upgraded to WS: %v", err)
		return
	}
	log.Printf("HTTP upgraded to WS for %s", r.RemoteAddr)
	defer ws.Close()

	colsStr := r.URL.Query().Get("cols")
	rowsStr := r.URL.Query().Get("rows")
	log.Printf("Received initial dimensions: cols=%s, rows=%s", colsStr, rowsStr)

	cols, _ := strconv.Atoi(colsStr)
	rows, _ := strconv.Atoi(rowsStr)
	if cols == 0 {
		cols = 80 // Default
	}
	if rows == 0 {
		rows = 40 // Default
	}

	// For now, this example just connects to the first client.
	// A real implementation would select the client based on the request.
	if len(clients) == 0 {
		log.Println("No clients configured")
		ws.WriteMessage(websocket.TextMessage, []byte("No remote clients are configured on the server."))
		return
	}
	client := clients[0] // Connect to the first client

	sshClient, err := connectSSH(client.username, client.password, client.addr)
	if err != nil {
		log.Printf("SSH connection failed for %s: %v", client.username, err)
		ws.WriteMessage(websocket.TextMessage, []byte("SSH connection error"))
		return
	}
	defer sshClient.Close()
	log.Printf("SSH connection successful for %s", client.username)

	sshSession, sshStdin, sshStdout, sshStderr, err := setupSSHSession(sshClient, rows, cols)
	if err != nil {
		log.Printf("SSH session setup failed for %s: %v", client.username, err)
		ws.WriteMessage(websocket.TextMessage, []byte("SSH session setup failed"))
		return
	}
	defer sshSession.Close()
	log.Printf("SSH session setup successful for %s", client.username)

	if err := startPiping(ws, sshStdin, sshStdout, sshStderr, sshSession); err != nil {
		log.Printf("Piping error for %s: %v", client.username, err)
	}

	log.Printf("Session closed for %s", client.username)
}

func home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	log.Printf("Serving index.html to %s", r.RemoteAddr)
	http.ServeFile(w, r, "index.html")
}

func main() {
	flag.Parse()
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)

	log.Println("Meshell Server is starting...")

	http.HandleFunc("/tty", tty)
	log.Println("Registered handler for /tty")

	http.HandleFunc("/", home)
	log.Println("Registered handler for /")

	http.Handle("/node_modules/", http.StripPrefix("/node_modules/", http.FileServer(http.Dir("node_modules"))))
	log.Println("Registered handler for /node_modules/")

	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))
	log.Println("Registered handler for /static/")

	log.Printf("Server listening on address %s", *addr)
	err := http.ListenAndServe(*addr, nil)
	if err != nil {
		log.Fatalf("Fatal error during ListenAndServe: %v", err)
	}
}