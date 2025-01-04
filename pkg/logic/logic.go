package logic

import (
	"context"

	"github.com/grzegorzgniadek/argocd-appset-substitute-plugin/pkg/client"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

var (
	clientset = client.K8SClient()
)

func GetSecretData(namespace, secretName string) (map[string]string, error) {
	// Get the secret
	secret, err := clientset.CoreV1().Secrets(namespace).Get(context.TODO(), secretName, metav1.GetOptions{})
	if err != nil {
		return nil, err
	}

	// Convert data to map[string]string
	data := make(map[string]string)
	for key, value := range secret.Data {
		data[key] = string(value)
	}
	return data, nil
}

func GetConfigMapData(namespace, configMapName string) (map[string]string, error) {
	configmap, err := clientset.CoreV1().ConfigMaps(namespace).Get(context.TODO(), configMapName, metav1.GetOptions{})
	if err != nil {
		return nil, err
	}

	return configmap.Data, nil
}
