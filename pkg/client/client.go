package client

import (
	"k8s.io/cli-runtime/pkg/genericclioptions"
	"k8s.io/client-go/kubernetes"
)

func K8SClient() *kubernetes.Clientset {

	config, err := genericclioptions.NewConfigFlags(true).ToRESTConfig()
	if err != nil {
		panic(err)
	}
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(err)

	}
	return clientset
}
