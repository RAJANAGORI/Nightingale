package main

import (
	"context"
	"fmt"
	"github.com/docker/docker/api/types"
	"github.com/docker/docker/client"
	"io"
	"os"
)

func main() {
	imageName := "alpine:latest" // Change this to the image you want to pull

	// Create a Docker client
	cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if err != nil {
		fmt.Println("Error creating Docker client:", err)
		return
	}

	// Pull the image
	ctx := context.Background()
	out, err := cli.ImagePull(ctx, imageName, types.ImagePullOptions{})
	if err != nil {
		fmt.Println("Error pulling image:", err)
		return
	}
	defer out.Close()

	// Copy output to stdout
	io.Copy(os.Stdout, out)

	fmt.Println("\nImage pulled successfully")
}
