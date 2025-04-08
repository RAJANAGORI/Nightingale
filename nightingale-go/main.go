package main

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strings"
	"time"

	"github.com/schollz/progressbar/v3"
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
	case "update":
		if len(os.Args) < 4 || os.Args[2] != "local" {
			fmt.Println("Usage: nightingale-go update local <arch>")
			return
		}
		updateRepo()
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
	case "activate":
		activateEnvironment()
	case "metasploit":
		installMetasploit()
	case "zsh":
		installZsh()
	case "access":
		accessApplication()
	case "help":
		displayHelp()
	case "tools":
		listTools()
	default:
		fmt.Println("Invalid command")
		displayHelp()
	}
}

func shellCommand(command string) *exec.Cmd {
	if runtime.GOOS == "windows" {
		return exec.Command("cmd", "/C", command)
	}
	return exec.Command("sh", "-c", command)
}

func displayHelp() {
	fmt.Println("Usage: nightingale-go <command> <option>")
	fmt.Println("Commands:")
	fmt.Println("  start local <arch>      Start the Docker container with specified architecture (amd/arm)")
	fmt.Println("  activate                Activate the Python and GO Modules to support the tools")
	fmt.Println("  clone local             Clone the repository locally")
	fmt.Println("  build local <arch>      Build the Docker image locally for amd or arm")
	fmt.Println("  update local <arch>     Update the Docker image locally for amd or arm")
	fmt.Println("  access                  Access the application in the browser")
	fmt.Println("  metasploit              Installing and Activating Metasploit Framework")
	fmt.Println("  zsh                     Installing ZSH and Oh-My-Zsh")
	fmt.Println("  tools                   List all the tools available in the container")
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
		cmd = shellCommand("cd Nightingale && docker build -t rajanagori/nightingale:stable .")
	} else if arch == "arm" {
		cmd = shellCommand("cd Nightingale/architecture/arm64/v8 && docker buildx build --no-cache --platform linux/arm64 -t rajanagori/nightingale:arm64 .")
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

func updateRepo() {
	arch := os.Args[3]
	var image string

	if arch == "amd" {
		image = "ghcr.io/rajanagori/nightingale:stable"
	} else if arch == "arm" {
		image = "ghcr.io/rajanagori/nightingale:arm64"
	} else {
		fmt.Println("❌ Invalid architecture. Use 'amd' or 'arm'.")
		return
	}

	fmt.Println("🔄 Pulling image:", image)

	bar := progressbar.NewOptions(100,
		progressbar.OptionEnableColorCodes(true),
		progressbar.OptionSetDescription("Downloading..."),
		progressbar.OptionSetWidth(40),
		progressbar.OptionShowCount(),
		progressbar.OptionSetPredictTime(false),
	)

	cmd := exec.Command("docker", "pull", image)
	cmd.Stdout = nil
	cmd.Stderr = nil

	err := cmd.Start()
	if err != nil {
		fmt.Println("❌ Error pulling image:", image, err)
		return
	}

	for i := 0; i <= 100; i++ {
		bar.Set(i)
		time.Sleep(50 * time.Millisecond)
	}

	err = cmd.Wait()
	if err != nil {
		fmt.Println("❌ Error completing pull for:", image, err)
	} else {
		fmt.Println("\n✅ Successfully updated:", image)
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

	containerName := "Nightingale"

	checkRunningCmd := exec.Command("docker", "ps", "--filter", "name="+containerName, "--format", "{{.Names}}")
	runningOutput, err := checkRunningCmd.Output()
	if err != nil {
		fmt.Println("Error checking running containers:", err)
		return
	}

	if strings.TrimSpace(string(runningOutput)) == containerName {
		fmt.Println("Container of the same name is already running.")
		return
	}

	checkAllCmd := exec.Command("docker", "ps", "-a", "--filter", "name="+containerName, "--format", "{{.Names}}")
	allOutput, err := checkAllCmd.Output()
	if err != nil {
		fmt.Println("Error checking existing containers:", err)
		return
	}

	if strings.TrimSpace(string(allOutput)) == containerName {
		fmt.Println("A stopped container exists. Restart it with:")
		fmt.Printf("  docker start %s\n", containerName)
		fmt.Println("Or remove it using:")
		fmt.Printf("  docker rm %s\n", containerName)
		return
	}

	cmd := exec.Command("docker", "run", "-it", "--name", containerName, "-p", "8080:7681", "-d", image, "ttyd", "-p", "7681", "bash")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err = cmd.Run()
	if err != nil {
		fmt.Println("Error starting Docker container:", err)
	}
}

func activateEnvironment() {
	containerName := "Nightingale"

	fmt.Println("🔄 Activating Python and Go modules inside the container...")
	fmt.Println("⏳ This may take some time... Please wait.")

	// Run both install scripts in the background inside the container
	cmd := exec.Command("docker", "exec", containerName, "bash", "-c",
		"nohup ${SHELLS}/python-install-modules.sh >/dev/null 2>&1 & " +
			"nohup ${SHELLS}/go-install-modules.sh >/dev/null 2>&1 &")

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		fmt.Println("❌ Error activating environment:", err)
	} else {
		fmt.Println("✅ Python and Go module activation completed inside the container.")
	}
}

func installMetasploit() {
	containerName := "Nightingale"

	checkRunningCmd := exec.Command("docker", "ps", "--filter", "name="+containerName, "--format", "{{.Names}}")
	runningOutput, err := checkRunningCmd.Output()
	if err != nil {
		fmt.Println("Error checking running containers:", err)
		return
	}

	if strings.TrimSpace(string(runningOutput)) != containerName {
		fmt.Println("Error: The container", containerName, "is not running. Start it first using:")
		fmt.Println("  nightingale-go start local <arch>")
		return
	}

	fmt.Println("Installing Metasploit inside the container...")

	installCmds := []string{
		"curl -fsSL https://apt.metasploit.com/metasploit-framework.gpg.key | gpg --dearmor -o /usr/share/keyrings/metasploit.gpg",
		`echo "deb [signed-by=/usr/share/keyrings/metasploit.gpg] https://apt.metasploit.com/ buster main" > /etc/apt/sources.list.d/metasploit.list`,
		"apt update",
		"apt install -y metasploit-framework",
	}

	for _, cmdStr := range installCmds {
		cmd := exec.Command("docker", "exec", containerName, "bash", "-c", cmdStr)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			fmt.Println("Error executing:", cmdStr, "Error:", err)
			return
		}
	}

	fmt.Println("Metasploit installation complete inside the container.")
}

func installZsh() {
	containerName := "Nightingale"

	checkRunningCmd := exec.Command("docker", "ps", "--filter", "name="+containerName, "--format", "{{.Names}}")
	runningOutput, err := checkRunningCmd.Output()
	if err != nil {
		fmt.Println("Error checking running containers:", err)
		return
	}

	if strings.TrimSpace(string(runningOutput)) != containerName {
		fmt.Println("Error: The container", containerName, "is not running. Start it first using:")
		fmt.Println("  nightingale-go start local <arch>")
		return
	}

	fmt.Println("Activating Zsh inside the container...")

	cmdStr := `sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
	-t https://github.com/denysdovhan/spaceship-prompt \
	-a 'SPACESHIP_PROMPT_ADD_NEWLINE="true"' \
	-a 'SPACESHIP_PROMPT_SEPARATE_LINE="true"' \
	-p git \
	-p https://github.com/zsh-users/zsh-autosuggestions \
	-p https://github.com/zsh-users/zsh-completions &&\
	dos2unix ${HOME}/.zshrc &&\
	cat /tmp/banner.sh >> ${HOME}/.zshrc`

	cmd := exec.Command("docker", "exec", containerName, "bash", "-c", cmdStr)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		fmt.Println("Error activating Zsh inside the container:", err)
		return
	}

	fmt.Println("Zsh activation complete inside the container.")
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

	cmd := shellCommand(url)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		fmt.Println("Error accessing application:", err)
	}
}

func listTools() {
	fmt.Println("Available tools:")

	fmt.Println("  Operating System:")
	fmt.Println("    - Text Editor:")
	fmt.Println("      - vim")
	fmt.Println("      - nano")
	fmt.Println("    - Development Essentials:")
	fmt.Println("      - locate")
	fmt.Println("      - tree")
	fmt.Println("      - figlet")
	fmt.Println("      - ssh")
	fmt.Println("      - git")
	fmt.Println("      - curl")
	fmt.Println("      - wget")
	fmt.Println("      - file")
	fmt.Println("      - dos2unix")
	fmt.Println("    - Terminal Support:")
	fmt.Println("      - bash (default)")
	fmt.Println("      - zsh")
	fmt.Println("    - Compression Technique:")
	fmt.Println("      - unzip")
	fmt.Println("      - p7zip-full")
	fmt.Println("    - Network Essentials:")
	fmt.Println("      - htop")
	fmt.Println("      - traceroute")
	fmt.Println("      - telnet")
	fmt.Println("      - net-tools")
	fmt.Println("      - iputils-ping")
	fmt.Println("      - whois")
	fmt.Println("      - tor")
	fmt.Println("      - dnsutils")

	fmt.Println("\n  Web Application VAPT tools:")
	fmt.Println("    - Whatweb")
	fmt.Println("    - sqlmap")
	fmt.Println("    - amass")
	fmt.Println("    - assetfinder")
	fmt.Println("    - dirsearch")
	fmt.Println("    - ffuf")
	fmt.Println("    - findomain")
	fmt.Println("    - gau")
	fmt.Println("    - gf")
	fmt.Println("    - gobuster")
	fmt.Println("    - hawkscan")
	fmt.Println("    - httprobe")
	fmt.Println("    - httpx")
	fmt.Println("    - jwt_tool")
	fmt.Println("    - linkfinder")
	fmt.Println("    - masscan")
	fmt.Println("    - nuclei")
	fmt.Println("    - subfinder")
	fmt.Println("    - sublist3r")
	fmt.Println("    - waybackurls")
	fmt.Println("    - xray")
	fmt.Println("    - reconspider")
	fmt.Println("    - john")
	fmt.Println("    - hydra")
	fmt.Println("    - Arjun")
	fmt.Println("    - Katana")
	fmt.Println("    - Trufflehog")
	fmt.Println("    - Ghauri")
	fmt.Println("    - Detect-Secrets")
	fmt.Println("    - Gitleaks")

	fmt.Println("\n  Network VAPT tools:")
	fmt.Println("    - nmap")
	fmt.Println("    - metasploit")
	fmt.Println("    - Naabu")
	fmt.Println("    - RustScan")

	fmt.Println("\n  OSINT tools:")
	fmt.Println("    - Reconspider")
	fmt.Println("    - recon-ng")
	fmt.Println("    - spiderfoot")
	fmt.Println("    - metagoofil")
	fmt.Println("    - theHarvester")

	fmt.Println("\n  Mobile VAPT tools:")
	fmt.Println("    - adb")
	fmt.Println("    - apktool")
	fmt.Println("    - jdax")
	fmt.Println("    - Mobile Security Framework (MobSF)")
	fmt.Println("    - Runtime Mobile Security (RMS)")
	fmt.Println("    - android-framework-res")
	fmt.Println("    - frida-tools")
	fmt.Println("    - objection")

	fmt.Println("\n  Forensic and Red Team tools:")
	fmt.Println("    - impacket")
	fmt.Println("    - exiftool")
	fmt.Println("    - steghide")
	fmt.Println("    - binwalk")
	fmt.Println("    - foremost")

	fmt.Println("\n  Wordlist:")
	fmt.Println("    - wfuzz")
	fmt.Println("    - Seclists")
	fmt.Println("    - dirb")
	fmt.Println("    - rockyou.txt")
	fmt.Println("    - fuzzdb")
	fmt.Println("    - Node Dirbuster")

	fmt.Println("\n  Programming Language Support:")
	fmt.Println("    - Python 3")
	fmt.Println("    - Java")
	fmt.Println("    - Ruby")
	fmt.Println("    - Node.js")
	fmt.Println("    - Go")
}