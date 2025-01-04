package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/grzegorzgniadek/argocd-appset-substitute-plugin/pkg/envs"
	"github.com/grzegorzgniadek/argocd-appset-substitute-plugin/pkg/handlers"
)

func main() {
	// Define HTTP routes
	http.HandleFunc("/api/v1/getparams.execute", handlers.HandleGetParams)
	http.HandleFunc("/healthz", handlers.HandleHealthz)

	// Start the HTTP server
	port := envs.GetAppPort()
	token := handlers.PluginToken
	if token == "" {
		log.Printf("Failed to start server: Token is not defined \n")
		os.Exit(1)

	}
	log.Printf("Server starting on port %s\n", port)
	if err := http.ListenAndServe(fmt.Sprintf(":%s", port), nil); err != nil {
		log.Printf("Failed to start server: %v\n", err)
		os.Exit(1)
	}
}
