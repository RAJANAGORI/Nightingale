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

// Application metadata
const (
	appName    = "Nightingale"
	appVersion = "2.0.0"
	appAuthor  = "Raja Nagori"
	appEmail   = "raja.nagori@owasp.org"
	appLicense = "GPL-3.0 license"
)

// Container configuration
const (
	defaultContainerName = "Nightingale"
	defaultPort          = "8080"
	containerPort        = "7681"
	gottyCommand         = "gotty"
	defaultShell         = "bash"
)

// Image registry configuration
const (
	registryBase = "ghcr.io/rajanagori/nightingale"
	stableTag    = "stable"
	arm64Tag     = "arm64"
)

// Exit codes
const (
	exitSuccess = 0
	exitError   = 1
)

// Color codes for terminal output
const (
	colorReset  = "\033[0m"
	colorRed    = "\033[31m"
	colorGreen  = "\033[32m"
	colorYellow = "\033[33m"
	colorBlue   = "\033[34m"
	colorCyan   = "\033[36m"
)

// printColored prints colored text to stdout
func printColored(color, message string) {
	fmt.Printf("%s%s%s\n", color, message, colorReset)
}

// printError prints error message to stderr
func printError(message string) {
	fmt.Fprintf(os.Stderr, "%s[ERROR] %s%s\n", colorRed, message, colorReset)
}

// printSuccess prints success message
func printSuccess(message string) {
	printColored(colorGreen, "[SUCCESS] "+message)
}

// printInfo prints info message
func printInfo(message string) {
	printColored(colorBlue, "[INFO] "+message)
}

// printWarning prints warning message
func printWarning(message string) {
	printColored(colorYellow, "[WARN] "+message)
}

// validateArchitecture validates the provided architecture
func validateArchitecture(arch string) error {
	validArchs := []string{"amd", "arm"}
	for _, valid := range validArchs {
		if arch == valid {
			return nil
		}
	}
	return fmt.Errorf("invalid architecture '%s'. Valid options: amd, arm", arch)
}

// getImageName returns the appropriate Docker image name for the architecture
func getImageName(arch string) (string, error) {
	if err := validateArchitecture(arch); err != nil {
		return "", err
	}

	switch arch {
	case "amd":
		return fmt.Sprintf("%s:%s", registryBase, stableTag), nil
	case "arm":
		return fmt.Sprintf("%s:%s", registryBase, arm64Tag), nil
	default:
		return "", fmt.Errorf("unsupported architecture: %s", arch)
	}
}

// commandExists checks if a command is available in PATH
func commandExists(cmd string) bool {
	_, err := exec.LookPath(cmd)
	return err == nil
}

// shellCommand creates a platform-specific shell command
func shellCommand(command string) *exec.Cmd {
	if runtime.GOOS == "windows" {
		return exec.Command("cmd", "/C", command)
	}
	return exec.Command("sh", "-c", command)
}

// executeCommand executes a command and streams output
func executeCommand(cmd *exec.Cmd) error {
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

// cloneRepo clones the Nightingale repository locally
func cloneRepo() error {
	printInfo("Cloning Nightingale repository...")

	if !commandExists("git") {
		return fmt.Errorf("git is not installed. Please install git first")
	}

	cmd := exec.Command("git", "clone", "--depth", "1", "https://github.com/RAJANAGORI/Nightingale.git")
	if err := executeCommand(cmd); err != nil {
		return fmt.Errorf("failed to clone repository: %w", err)
	}

	printSuccess("Repository cloned successfully")
	return nil
}

// buildDockerImage builds a Docker image for the specified architecture
func buildDockerImage(arch string) error {
	printInfo(fmt.Sprintf("Building Docker image for %s architecture...", arch))

	if !commandExists("docker") {
		return fmt.Errorf("docker is not installed. Please install Docker first")
	}

	if err := validateArchitecture(arch); err != nil {
		return err
	}

	var cmd *exec.Cmd

	switch arch {
	case "amd":
		cmd = shellCommand("cd Nightingale && docker build -t rajanagori/nightingale:stable .")
	case "arm":
		cmd = shellCommand("cd Nightingale/architecture/arm64/v8 && docker buildx build --no-cache --platform linux/arm64 -t rajanagori/nightingale:arm64 .")
	default:
		return fmt.Errorf("unsupported architecture: %s", arch)
	}

	if err := executeCommand(cmd); err != nil {
		return fmt.Errorf("failed to build Docker image: %w", err)
	}

	printSuccess(fmt.Sprintf("Docker image built successfully for %s", arch))
	return nil
}

// updateRepo pulls the latest Docker image for the specified architecture
func updateRepo(arch string) error {
	printInfo("Updating Nightingale Docker image...")

	if !commandExists("docker") {
		return fmt.Errorf("docker is not installed. Please install Docker first")
	}

	image, err := getImageName(arch)
	if err != nil {
		return err
	}

	printInfo(fmt.Sprintf("Pulling image: %s", image))

	// Create progress bar
	bar := progressbar.NewOptions(100,
		progressbar.OptionEnableColorCodes(true),
		progressbar.OptionSetDescription("[cyan]Downloading...[reset]"),
		progressbar.OptionSetWidth(40),
		progressbar.OptionShowCount(),
		progressbar.OptionSetPredictTime(false),
		progressbar.OptionSetTheme(progressbar.Theme{
			Saucer:        "[green]=[reset]",
			SaucerHead:    "[green]>[reset]",
			SaucerPadding: " ",
			BarStart:      "[",
			BarEnd:        "]",
		}),
	)

	// Start docker pull in background
	cmd := exec.Command("docker", "pull", image)
	cmd.Stdout = nil
	cmd.Stderr = nil

	if err := cmd.Start(); err != nil {
		return fmt.Errorf("failed to start docker pull: %w", err)
	}

	// Simulate progress (in production, you'd parse docker pull output)
	for i := 0; i <= 100; i++ {
		_ = bar.Set(i)
		time.Sleep(50 * time.Millisecond)
	}

	// Wait for docker pull to complete
	if err := cmd.Wait(); err != nil {
		return fmt.Errorf("failed to pull image: %w", err)
	}

	fmt.Println() // New line after progress bar
	printSuccess(fmt.Sprintf("Successfully updated: %s", image))
	return nil
}

// containerExists checks if a container with the given name exists
func containerExists(name string) (bool, bool, error) {
	// Check if container is running
	runningCmd := exec.Command("docker", "ps", "--filter", "name="+name, "--format", "{{.Names}}")
	runningOutput, err := runningCmd.Output()
	if err != nil {
		return false, false, fmt.Errorf("failed to check running containers: %w", err)
	}

	isRunning := strings.TrimSpace(string(runningOutput)) == name

	// Check if container exists (running or stopped)
	allCmd := exec.Command("docker", "ps", "-a", "--filter", "name="+name, "--format", "{{.Names}}")
	allOutput, err := allCmd.Output()
	if err != nil {
		return false, false, fmt.Errorf("failed to check existing containers: %w", err)
	}

	exists := strings.TrimSpace(string(allOutput)) == name

	return exists, isRunning, nil
}

// startDockerContainer starts the Nightingale Docker container
func startDockerContainer(arch, protocol string) error {
	printInfo("Starting Nightingale container...")

	if !commandExists("docker") {
		return fmt.Errorf("docker is not installed. Please install Docker first")
	}

	image, err := getImageName(arch)
	if err != nil {
		return err
	}

	containerName := defaultContainerName

	// Check if container exists
	exists, isRunning, err := containerExists(containerName)
	if err != nil {
		return err
	}

	if isRunning {
		printWarning("Container is already running")
		printInfo(fmt.Sprintf("Access it at: %s://localhost:%s", protocol, defaultPort))
		return nil
	}

	if exists {
		printWarning("A stopped container exists. Please choose an option:")
		fmt.Println("  1. Restart it:  docker start " + containerName)
		fmt.Println("  2. Remove it:   docker rm " + containerName)
		return fmt.Errorf("container already exists but is stopped")
	}

	// Start new container
	printInfo(fmt.Sprintf("Starting new container with image: %s", image))
	printInfo(fmt.Sprintf("Protocol: %s", protocol))

	var cmd *exec.Cmd
	if protocol == "https" {
		// HTTPS with TLS
		cmd = exec.Command("docker", "run", "-it",
			"--name", containerName,
			"-p", fmt.Sprintf("%s:%s", defaultPort, containerPort),
			"-d", image,
			gottyCommand, "-p", containerPort, "-t", "--tls-crt", "/root/.gotty.crt", "--tls-key", "/root/.gotty.key", "-w", "--reconnect", "--reconnect-time", "1", "--timeout", "0", defaultShell, "-i")
	} else {
		// HTTP (default)
		cmd = exec.Command("docker", "run", "-it",
			"--name", containerName,
			"-p", fmt.Sprintf("%s:%s", defaultPort, containerPort),
			"-d", image,
			gottyCommand, "-p", containerPort, "-w", "--reconnect", "--reconnect-time", "1", "--timeout", "0", defaultShell, "-i")
	}

	if err := executeCommand(cmd); err != nil {
		return fmt.Errorf("failed to start container: %w", err)
	}

	printSuccess(fmt.Sprintf("Container started successfully: %s", containerName))
	printInfo(fmt.Sprintf("Access it at: %s://localhost:%s", protocol, defaultPort))
	return nil
}

// activateEnvironment activates Python and Go modules inside the container
func activateEnvironment() error {
	printInfo("Activating Python and Go modules inside the container...")
	printWarning("This may take some time... Please wait.")

	containerName := defaultContainerName

	// Verify container is running
	exists, isRunning, err := containerExists(containerName)
	if err != nil {
		return err
	}

	if !exists {
		return fmt.Errorf("container '%s' does not exist. Start it first using: nightingale-go start local <arch>", containerName)
	}

	if !isRunning {
		return fmt.Errorf("container '%s' exists but is not running. Start it with: docker start %s", containerName, containerName)
	}

	// Run activation scripts in background
	scriptCmd := "${SHELLS}/python-install-modules.sh >/dev/null 2>&1 & " +
		"${SHELLS}/go-install-modules.sh >/dev/null 2>&1 &"

	cmd := exec.Command("docker", "exec", containerName, "bash", "-c", scriptCmd)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to activate environment: %w", err)
	}

	printSuccess("Python and Go module activation initiated inside the container")
	printInfo("Modules are being installed in the background")
	return nil
}

// installMetasploit installs Metasploit Framework inside the container
func installMetasploit() error {
	printInfo("Installing Metasploit Framework...")

	containerName := defaultContainerName

	// Verify container is running
	exists, isRunning, err := containerExists(containerName)
	if err != nil {
		return err
	}

	if !exists || !isRunning {
		return fmt.Errorf("container '%s' is not running. Start it first using: nightingale-go start local <arch>", containerName)
	}

	printInfo("This will take several minutes. Please be patient...")

	installCommands := []string{
		"curl -fsSL https://apt.metasploit.com/metasploit-framework.gpg.key | gpg --dearmor -o /usr/share/keyrings/metasploit.gpg",
		`echo "deb [signed-by=/usr/share/keyrings/metasploit.gpg] https://apt.metasploit.com/ buster main" > /etc/apt/sources.list.d/metasploit.list`,
		"apt update",
		"apt install -y metasploit-framework",
	}

	for i, cmdStr := range installCommands {
		printInfo(fmt.Sprintf("Step %d/%d: Running installation command...", i+1, len(installCommands)))

		cmd := exec.Command("docker", "exec", containerName, "bash", "-c", cmdStr)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr

		if err := cmd.Run(); err != nil {
			return fmt.Errorf("installation failed at step %d: %w", i+1, err)
		}
	}

	printSuccess("Metasploit Framework installed successfully")
	return nil
}

// installZsh installs and configures Zsh inside the container
func installZsh() error {
	printInfo("Installing and configuring Zsh...")

	containerName := defaultContainerName

	// Verify container is running
	exists, isRunning, err := containerExists(containerName)
	if err != nil {
		return err
	}

	if !exists || !isRunning {
		return fmt.Errorf("container '%s' is not running. Start it first using: nightingale-go start local <arch>", containerName)
	}

	printInfo("Installing Zsh with Oh-My-Zsh and plugins...")

	cmdStr := `sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
	-t https://github.com/denysdovhan/spaceship-prompt \
	-a 'SPACESHIP_PROMPT_ADD_NEWLINE="true"' \
	-a 'SPACESHIP_PROMPT_SEPARATE_LINE="true"' \
	-p git \
	-p https://github.com/zsh-users/zsh-autosuggestions \
	-p https://github.com/zsh-users/zsh-completions &&\
	dos2unix ${HOME}/.zshrc 2>/dev/null || true &&\
	cat /tmp/banner.sh >> ${HOME}/.zshrc 2>/dev/null || true`

	cmd := exec.Command("docker", "exec", containerName, "bash", "-c", cmdStr)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to install Zsh: %w", err)
	}

	printSuccess("Zsh installed and configured successfully")
	printInfo("Restart your shell or run 'zsh' to use it")
	return nil
}

// accessApplication opens the Nightingale web interface in the default browser
func accessApplication() error {
	printInfo("Opening Nightingale in your default browser...")

	var cmd *exec.Cmd
	url := fmt.Sprintf("http://localhost:%s", defaultPort)

	switch runtime.GOOS {
	case "windows":
		cmd = exec.Command("cmd", "/c", "start", url)
	case "darwin":
		cmd = exec.Command("open", url)
	default: // linux and others
		cmd = exec.Command("xdg-open", url)
	}

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		printWarning("Could not open browser automatically")
		printInfo(fmt.Sprintf("Please open this URL manually: %s", url))
		return nil
	}

	printSuccess(fmt.Sprintf("Browser opened at: %s", url))
	return nil
}

// listTools displays a comprehensive list of available tools
func listTools() {
	fmt.Println()
	printColored(colorCyan, "╔════════════════════════════════════════════════════════════╗")
	printColored(colorCyan, "║         NIGHTINGALE - Available Security Tools            ║")
	printColored(colorCyan, "╚════════════════════════════════════════════════════════════╝")
	fmt.Println()

	categories := map[string][]string{
		"Operating System": {
			"Text Editors: vim, nano",
			"Development: git, curl, wget, file, dos2unix",
			"Terminals: bash (default), zsh (optional)",
			"Compression: unzip, p7zip-full",
			"Network Utilities: htop, traceroute, telnet, net-tools",
			"Tools: iputils-ping, whois, tor, dnsutils",
		},
		"Web Application VAPT": {
			"Reconnaissance: whatweb, amass, assetfinder, subfinder",
			"Discovery: dirsearch, ffuf, gobuster, dirb",
			"Scanning: nuclei, hawkscan, xray, masscan",
			"Testing: sqlmap, ghauri, xsstrike, arjun",
			"Utilities: httprobe, httpx, gau, waybackurls, katana",
			"Security: jwt_tool, linkfinder, gf (grep patterns)",
			"Secrets: trufflehog, detect-secrets, gitleaks",
			"Brute Force: john, hydra, medusa, hashcat",
		},
		"Network VAPT": {
			"Scanners: nmap, masscan, naabu, rustscan",
			"Framework: metasploit (optional installation)",
			"Packet Analysis: tcpdump",
			"VPN: openvpn",
		},
		"OSINT Tools": {
			"Frameworks: reconspider, recon-ng, spiderfoot",
			"Information Gathering: metagoofil, theHarvester",
		},
		"Mobile VAPT": {
			"Android: adb, apktool, jadx",
			"Frameworks: MobSF, RMS (Runtime Mobile Security)",
			"Dynamic Analysis: frida-tools, objection",
			"Resources: android-framework-res",
		},
		"Forensics & Red Team": {
			"Network: impacket",
			"Metadata: exiftool",
			"Steganography: steghide",
			"Analysis: binwalk, foremost",
		},
		"Wordlists": {
			"Collections: SecLists, rockyou.txt, fuzzdb",
			"Tools: wfuzz, dirb wordlists, node-dirbuster",
		},
		"Programming Languages": {
			"Python 3: Latest with pip and pipx",
			"Java: JDK for Java-based tools",
			"Ruby: For Metasploit and Ruby tools",
			"Node.js: JavaScript runtime with npm",
			"Go: For modern security tools",
		},
	}

	for category, tools := range categories {
		printColored(colorBlue, fmt.Sprintf("▶ %s:", category))
		for _, tool := range tools {
			fmt.Printf("  • %s\n", tool)
		}
		fmt.Println()
	}

	printInfo("For detailed documentation, visit: https://github.com/RAJANAGORI/Nightingale/wiki")
	fmt.Println()
}

// displayHelp shows usage information
func displayHelp() {
	fmt.Println()
	printColored(colorCyan, "╔════════════════════════════════════════════════════════════╗")
	printColored(colorCyan, fmt.Sprintf("║  %s v%s - Docker for Pentesters                ║", appName, appVersion))
	printColored(colorCyan, "╚════════════════════════════════════════════════════════════╝")
	fmt.Println()

	fmt.Println("USAGE:")
	fmt.Println("  nightingale-go <command> [options]")
	fmt.Println()

	fmt.Println("COMMANDS:")
	printColored(colorGreen, "  Container Management:")
	fmt.Println("    start local <arch> [protocol]    Start Nightingale container (arch: amd/arm, protocol: http/https)")
	fmt.Println("    access                           Open web interface in browser")
	fmt.Println()

	printColored(colorGreen, "  Module Management:")
	fmt.Println("    activate              Install Python and Go modules")
	fmt.Println("    metasploit            Install Metasploit Framework")
	fmt.Println("    zsh                   Install and configure Zsh")
	fmt.Println()

	printColored(colorGreen, "  Image Management:")
	fmt.Println("    clone local           Clone repository locally")
	fmt.Println("    build local <arch>    Build Docker image (arch: amd/arm)")
	fmt.Println("    update local <arch>   Update Docker image (arch: amd/arm)")
	fmt.Println()

	printColored(colorGreen, "  Information:")
	fmt.Println("    tools                 List all available tools")
	fmt.Println("    help                  Display this help message")
	fmt.Println("    version               Show version information")
	fmt.Println()

	fmt.Println("EXAMPLES:")
	fmt.Println("  nightingale-go start local amd")
	fmt.Println("  nightingale-go start local amd https")
	fmt.Println("  nightingale-go start local arm http")
	fmt.Println("  nightingale-go update local arm")
	fmt.Println("  nightingale-go activate")
	fmt.Println("  nightingale-go metasploit")
	fmt.Println()

	fmt.Println("MORE INFORMATION:")
	fmt.Println("  GitHub: https://github.com/RAJANAGORI/Nightingale")
	fmt.Println("  Wiki:   https://github.com/RAJANAGORI/Nightingale/wiki")
	fmt.Printf("  Email:  %s\n", appEmail)
	fmt.Println()
}

// displayVersion shows version information
func displayVersion() {
	fmt.Println()
	printColored(colorCyan, fmt.Sprintf("%s v%s", appName, appVersion))
	fmt.Printf("Author:  %s\n", appAuthor)
	fmt.Printf("Email:   %s\n", appEmail)
	fmt.Printf("License: %s\n", appLicense)
	fmt.Printf("OS/Arch: %s/%s\n", runtime.GOOS, runtime.GOARCH)
	fmt.Println()
	fmt.Println("Part of: Nightingale - Docker for Pentesters")
	fmt.Println("         OWASP Incubator Project")
	fmt.Println()
}

// main is the entry point of the application
func main() {
	// Check if no arguments provided
	if len(os.Args) < 2 {
		printError("No command provided")
		fmt.Println()
		displayHelp()
		os.Exit(exitError)
	}

	command := os.Args[1]

	// Handle commands
	var err error

	switch command {
	case "clone":
		if len(os.Args) < 3 || os.Args[2] != "local" {
			printError("Usage: nightingale-go clone local")
			os.Exit(exitError)
		}
		err = cloneRepo()

	case "build":
		if len(os.Args) < 4 || os.Args[2] != "local" {
			printError("Usage: nightingale-go build local <arch>")
			printInfo("Valid architectures: amd, arm")
			os.Exit(exitError)
		}
		arch := os.Args[3]
		err = buildDockerImage(arch)

	case "update":
		if len(os.Args) < 4 || os.Args[2] != "local" {
			printError("Usage: nightingale-go update local <arch>")
			printInfo("Valid architectures: amd, arm")
			os.Exit(exitError)
		}
		arch := os.Args[3]
		err = updateRepo(arch)

	case "start":
		if len(os.Args) < 4 {
			printError("Usage: nightingale-go start local <arch> [protocol]")
			printInfo("Valid architectures: amd, arm")
			printInfo("Valid protocols: http, https (default: http)")
			os.Exit(exitError)
		}
		option := os.Args[2]
		arch := os.Args[3]
		protocol := "http" // default
		if len(os.Args) >= 5 {
			protocol = os.Args[4]
		}
		if option == "local" {
			err = startDockerContainer(arch, protocol)
		} else {
			printError("Invalid option. Use 'local'")
			os.Exit(exitError)
		}

	case "activate":
		err = activateEnvironment()

	case "metasploit":
		err = installMetasploit()

	case "zsh":
		err = installZsh()

	case "access":
		err = accessApplication()

	case "tools":
		listTools()

	case "help", "-h", "--help":
		displayHelp()

	case "version", "-v", "--version":
		displayVersion()

	default:
		printError(fmt.Sprintf("Unknown command: %s", command))
		fmt.Println()
		displayHelp()
		os.Exit(exitError)
	}

	// Handle any errors
	if err != nil {
		printError(err.Error())
		os.Exit(exitError)
	}

	os.Exit(exitSuccess)
}
