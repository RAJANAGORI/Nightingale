package main

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
)

func main() {
	if len(os.Args) < 2 {
		displayHelp()
		return
	}

	command := os.Args[1]

	switch command {
	case "clone":
		if len(os.Args) < 3 || os.Args[2] != "local" {
			fmt.Println("Usage: nightingale-go clone local")
			return
		}
		cloneRepo()
	case "build":
		if len(os.Args) < 4 || os.Args[2] != "local" {
			fmt.Println("Usage: nightingale-go build local <arch>")
			return
		}
		arch := os.Args[3]
		buildDockerImage(arch)
	case "start":
		if len(os.Args) < 4 {
			fmt.Println("Usage: nightingale-go start local <arch>")
			return
		}
		option := os.Args[2]
		arch := os.Args[3]
		if option == "local" {
			startDockerContainer(arch)
		} else {
			fmt.Println("Invalid option for start command")
		}
	case "access":
		accessApplication()
	case "help":
		displayHelp()
	default:
		fmt.Println("Invalid command")
		displayHelp()
	}
}

func displayHelp() {
	fmt.Println("Usage: nightingale-go <command> <option>")
	fmt.Println("Commands:")
	fmt.Println("  clone local             Clone the repository locally")
	fmt.Println("  build local <arch>      Build the Docker image locally for amd or arm")
	fmt.Println("  start local <arch>      Start the Docker container with specified architecture (amd/arm)")
	fmt.Println("  access                  Access the application in the browser")
	fmt.Println("  help                    Display this help message")
}

func cloneRepo() {
	cmd := exec.Command("git", "clone", "--depth", "1", "https://github.com/RAJANAGORI/Nightingale.git")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		fmt.Println("Error cloning repository:", err)
	}
}

func buildDockerImage(arch string) {
	var cmd *exec.Cmd
	if arch == "amd" {
		cmd = exec.Command("sh", "-c", "cd Nightingale && docker build -t rajanagori/nightingale:stable .")
	} else if arch == "arm" {
		cmd = exec.Command("sh", "-c", "cd Nightingale/architecture/arm64/v8 && docker buildx build --platform linux/arm64 -t rajanagori/nightingale:arm64 .")
	} else {
		fmt.Println("Invalid architecture")
		return
	}

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		fmt.Println("Error building Docker image:", err)
	}
}

func startDockerContainer(arch string) {
	var image string
	if arch == "amd" {
		image = "ghcr.io/rajanagori/nightingale:stable"
	} else if arch == "arm" {
		image = "ghcr.io/rajanagori/nightingale:arm64"
	} else {
		fmt.Println("Invalid architecture")
		return
	}

	cmd := exec.Command("docker", "run", "-it", "-p", "8080:7681", "-d", image, "ttyd", "-p", "7681", "bash")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		fmt.Println("Error starting Docker container:", err)
	}
}

func accessApplication() {
	var url string
	if runtime.GOOS == "windows" {
		url = "start http://localhost:8080"
	} else if runtime.GOOS == "darwin" {
		url = "open http://localhost:8080"
	} else {
		url = "xdg-open http://localhost:8080"
	}

	cmd := exec.Command("sh", "-c", url)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		fmt.Println("Error accessing application:", err)
	}
}