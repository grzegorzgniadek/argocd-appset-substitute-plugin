package envs

import (
	"log"
	"os"
)

func GetAppPort() string {
	port, ok := os.LookupEnv("APP_PORT")
	if !ok {
		port = "4535"
		log.Printf("Using default port %s \n", port)
	}
	return port
}

func GetToken() string {
	// Read the plugin token
	data, err := os.ReadFile("token")
	log.Printf("Using data from file token")
	if err != nil {
		log.Printf("Error reading data from: %v\n", err)
		log.Printf("Using environment variable APP_TOKEN")
		data = []byte(os.Getenv("APP_TOKEN"))
	}

	if len(data) == 0 {
		log.Println("Token is not set in file or environment variable")
	}
	pluginToken := string(data)
	return pluginToken
}
