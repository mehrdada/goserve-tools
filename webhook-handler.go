package main

import (
	"fmt"
	"net/http"
	"os/exec"
)

const bind = "127.0.0.1:7999"
const url = "/__ctrl/hook-uuid"
const cmdline = "deploy-app"

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "WebHook Called %s", r.URL.Path[1:])
	cmd := exec.Command(cmdline)
	cmd.Start()
}

func main() {
	http.HandleFunc(url, handler)
	http.ListenAndServe(bind, nil)
}
