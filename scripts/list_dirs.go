package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

func buildDirs(entries []os.DirEntry) []string {
	dirs := make([]string, 0)
	for _, entry := range entries {
		if entry.IsDir() {
			dirs = append(dirs, entry.Name())
		}
	}
	return dirs
}

func listDirs(dirs []string) {
	for i, dir := range dirs {
		fmt.Fprintf(os.Stderr, "%d. %s\n", i, dir)
	}
}

func main() {
	var n int
	var maxChoice int
	var choice string

	pwd, err := os.Getwd()
	if err != nil {
		log.Println(err)
		fmt.Fprintf(os.Stderr, "%s", err)
	}

	entries, err := os.ReadDir(pwd)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Non posso leggere la directory: %s\n", err)
	}

	dirs := buildDirs(entries)
	// Add "." and ".." to the beginning of the list
	dirs = append([]string{".", ".."}, dirs...)
	maxChoice = len(dirs) - 1

	listDirs(dirs)

	fmt.Fprintf(os.Stderr, "Seleziona una cartella:")

	scanner := bufio.NewScanner(os.Stdin)

	for {
		if scanner.Scan() {
			input := strings.TrimSpace(scanner.Text())
			if input == "" {
				continue
			}
			n, err = strconv.Atoi(input)
			if err != nil {
				fmt.Fprintf(os.Stderr, "Input non valido, inserisci un numero tra 0 e %d\n", maxChoice)
				continue
			}

			if n >= 0 && n <= maxChoice {
				choice = dirs[n]
				break
			} else {
				fmt.Fprintf(os.Stderr, "Valore fuori dal range. Puoi scegliere da 0 a %d\n", maxChoice)
			}
		}
	}
	fmt.Printf("%s", choice)
}

