package handlers

import (
	"argocd-substitute-plugin/pkg/envs"
	"argocd-substitute-plugin/pkg/logic"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
)

var (
	PluginToken = envs.GetToken()
)

// HTTP handler for /api/v1/getparams.execute
func HandleGetParams(w http.ResponseWriter, r *http.Request) {

	// Validate Authorization header
	auth := r.Header.Get("Authorization")
	if auth != "Bearer "+PluginToken {
		http.Error(w, "Forbidden", http.StatusForbidden)
		return
	}

	// Parse request body
	body, err := io.ReadAll(r.Body)
	defer r.Body.Close()
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	var request struct {
		ApplicationSetName string `json:"applicationSetName"`
		Input              struct {
			Parameters struct {
				Kind      string `json:"kind"`
				Name      string `json:"name"`
				Namespace string `json:"namespace"`
			} `json:"parameters"`
		} `json:"input"`
	}

	err = json.Unmarshal(body, &request)
	if err != nil || request.Input.Parameters.Name == "" || request.Input.Parameters.Namespace == "" || request.Input.Parameters.Kind == "" {
		http.Error(w, "Invalid JSON or missing parameters", http.StatusBadRequest)
		return
	}

	data := make(map[string]string)
	switch request.Input.Parameters.Kind {
	case "Secret":
		data, err = logic.GetSecretData(request.Input.Parameters.Namespace, request.Input.Parameters.Name)
	case "ConfigMap":
		data, err = logic.GetConfigMapData(request.Input.Parameters.Namespace, request.Input.Parameters.Name)
	default:
		http.Error(w, "Invalid type. Must be 'Secret' or 'ConfigMap'", http.StatusBadRequest)
		return
	}

	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to get %s: %v", request.Input.Parameters.Kind, err), http.StatusInternalServerError)
		return
	}

	// Transform the data into the required structure
	parameters := []map[string]string{}
	dynamicParams := make(map[string]string)
	for key, value := range data {
		dynamicParams[key] = value
	}
	parameters = append(parameters, dynamicParams)
	// Build the response
	response := map[string]interface{}{
		"output": map[string]interface{}{
			"parameters": parameters,
		},
	}

	// Send the response
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	log.Printf("Getting data from Kind: %s, Name: %s, Namespace: %s", request.Input.Parameters.Kind, request.Input.Parameters.Name, request.Input.Parameters.Namespace)
	json.NewEncoder(w).Encode(response)
}

// HTTP handler for /healthz
func HandleHealthz(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusCreated)
	w.Header().Set("Content-Type", "application/json")
	resp := make(map[string]string)
	resp["message"] = "Healthy"
	jsonResp, err := json.Marshal(resp)
	if err != nil {
		log.Fatalf("Error in JSON marshal, Err %s", err)
	}
	w.Write(jsonResp)
	return
}
