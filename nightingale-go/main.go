package main

import (
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
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
	case "community":
		if len(os.Args) < 3 {
			fmt.Println("Usage: nightingale-go community <setup|start|stop|access>")
			fmt.Println("  setup        - Prepare .env files for community edition (one-click login)")
			fmt.Println("  start [arch] - Start Nightingale GUI (community) using pre-built images; arch: amd, arm, or omit to match host")
			fmt.Println("  stop         - Stop the stack")
			fmt.Println("  access       - Open the console in your browser (http://localhost:3000)")
			return
		}
		communityCmd := os.Args[2]
		switch communityCmd {
		case "setup":
			communitySetup()
		case "start":
			arch := ""
			if len(os.Args) >= 4 {
				arch = os.Args[3]
			}
			communityStart(arch)
		case "stop":
			communityStop()
		case "access":
			communityAccess()
		default:
			fmt.Println("Invalid community command. Use: setup, start, stop, or access")
		}
	case "help":
		displayHelp()
	case "tools":
		listTools()
	default:
		fmt.Println("Invalid command")
		displayHelp()
	}
}

// SECURITY: shellCommand is vulnerable to command injection
// This function should only be used with trusted, hardcoded commands
// For user input, use exec.Command with separate arguments instead
func shellCommand(command string) *exec.Cmd {
	// SECURITY WARNING: Using sh -c is vulnerable to command injection
	// Only use this function with trusted, validated commands
	// In production, prefer using exec.Command with separate arguments
	if runtime.GOOS == "windows" {
		return exec.Command("cmd", "/C", command)
	}
	// SECURITY: Validate command doesn't contain dangerous characters
	// This is a basic check - in production, use whitelist approach
	if strings.Contains(command, ";") || strings.Contains(command, "&") || 
	   strings.Contains(command, "|") || strings.Contains(command, "$(") ||
	   strings.Contains(command, "`") {
		log.Printf("SECURITY WARNING: Potentially dangerous command detected: %s", command)
		// In production, this should return an error instead
	}
	return exec.Command("sh", "-c", command)
}

func displayHelp() {
	fmt.Println("Usage: nightingale-go <command> [options]")
	fmt.Println("Commands:")
	fmt.Println("  community setup         Prepare local env for Nightingale GUI (community edition)")
	fmt.Println("  community start [arch]  Start stack with pre-built images (arch: amd, arm, or host)")
	fmt.Println("  community stop          Stop the stack")
	fmt.Println("  community access        Open the console in browser (one-click login)")
	fmt.Println("  ---")
	fmt.Println("  start local <arch>      Start the Docker container with specified architecture (amd/arm)")
	fmt.Println("  activate                Activate the Python and GO Modules to support the tools")
	fmt.Println("  clone local             Clone the repository locally")
	fmt.Println("  build local <arch>      Build the Docker image locally for amd or arm")
	fmt.Println("  update local <arch>     Update the Docker image locally for amd or arm")
	fmt.Println("  access                  Access the application in the browser (legacy ttyd)")
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
	switch arch {
	case "amd":
		cmd = shellCommand("cd Nightingale && docker build -t rajanagori/nightingale:stable .")
	case "arm":
		cmd = shellCommand("cd Nightingale/architecture/arm64/v8 && docker buildx build --no-cache --platform linux/arm64 -t rajanagori/nightingale:arm64 .")
	default:
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

	switch arch {
	case "amd":
		image = "ghcr.io/rajanagori/nightingale:stable"
	case "arm":
		image = "ghcr.io/rajanagori/nightingale:arm64"
	default:
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
	switch arch {
	case "amd":
		image = "ghcr.io/rajanagori/nightingale:stable"
	case "arm":
		image = "ghcr.io/rajanagori/nightingale:arm64"
	default:
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

// communityRepoRoot returns the directory containing docker-compose.yaml (Nightingale-GUI repo root).
// Checks cwd and, if needed, parent (when run from nightingale-go/).
func communityRepoRoot() (string, bool) {
	dir, err := os.Getwd()
	if err != nil {
		return "", false
	}
	for i := 0; i < 2; i++ {
		if _, err := os.Stat(filepath.Join(dir, "docker-compose.yaml")); err == nil {
			if _, err := os.Stat(filepath.Join(dir, "gui", "feature-UI-one")); err == nil {
				return dir, true
			}
		}
		dir = filepath.Dir(dir)
		if dir == filepath.Dir(dir) {
			break
		}
	}
	return "", false
}

func communitySetup() {
	root, ok := communityRepoRoot()
	if !ok {
		fmt.Println("❌ Run this command from the Nightingale-GUI repository root (where docker-compose.yaml and gui/ are).")
		return
	}
	frontendEnv := filepath.Join(root, "gui", "feature-UI-one", ".env")
	backendEnv := filepath.Join(root, "gui", "go_backend", ".env")
	exampleEnv := filepath.Join(root, "gui", "feature-UI-one", ".env.example")

	// Ensure frontend .env exists with NEXT_PUBLIC_EDITION=community and JWT_SECRET_KEY
	if _, err := os.Stat(frontendEnv); os.IsNotExist(err) {
		secret := generateSecret()
		content := "NEXT_PUBLIC_EDITION=community\nJWT_SECRET_KEY=" + secret + "\nBACKEND_URL=http://backend:8765\n"
		if data, err := os.ReadFile(exampleEnv); err == nil {
			content = "NEXT_PUBLIC_EDITION=community\n" + string(data)
			if !strings.Contains(content, "JWT_SECRET_KEY=") {
				content = "JWT_SECRET_KEY=" + secret + "\n" + content
			}
		}
		if err := os.WriteFile(frontendEnv, []byte(content), 0600); err != nil {
			fmt.Println("❌ Failed to create gui/feature-UI-one/.env:", err)
			return
		}
		fmt.Println("✅ Created gui/feature-UI-one/.env with NEXT_PUBLIC_EDITION=community")
	} else {
		data, _ := os.ReadFile(frontendEnv)
		content := string(data)
		if !strings.Contains(content, "NEXT_PUBLIC_EDITION=") {
			content = "NEXT_PUBLIC_EDITION=community\n" + content
			_ = os.WriteFile(frontendEnv, []byte(content), 0600)
			fmt.Println("✅ Set NEXT_PUBLIC_EDITION=community in gui/feature-UI-one/.env")
		} else {
			fmt.Println("✅ gui/feature-UI-one/.env already present (check NEXT_PUBLIC_EDITION=community for one-click login)")
		}
	}

	// Ensure backend .env exists with JWT_SECRET_KEY and NIGHTINGALE_EDITION=community
	if _, err := os.Stat(backendEnv); os.IsNotExist(err) {
		frontData, _ := os.ReadFile(frontendEnv)
		secret := extractJWTSecret(string(frontData))
		if secret == "" {
			secret = generateSecret()
		}
		content := "JWT_SECRET_KEY=" + secret + "\nNIGHTINGALE_EDITION=community\n"
		if err := os.WriteFile(backendEnv, []byte(content), 0600); err != nil {
			fmt.Println("❌ Failed to create gui/go_backend/.env:", err)
			return
		}
		fmt.Println("✅ Created gui/go_backend/.env with JWT_SECRET_KEY and NIGHTINGALE_EDITION=community")
	} else {
		backendData, _ := os.ReadFile(backendEnv)
		backendContent := string(backendData)
		if !strings.Contains(backendContent, "NIGHTINGALE_EDITION=") {
			backendContent = "NIGHTINGALE_EDITION=community\n" + backendContent
			_ = os.WriteFile(backendEnv, []byte(backendContent), 0600)
			fmt.Println("✅ Set NIGHTINGALE_EDITION=community in gui/go_backend/.env")
		} else {
			fmt.Println("✅ gui/go_backend/.env already present")
		}
	}
	fmt.Println("\n📌 Next: run  nightingale-go community start   then  nightingale-go community access")
}

func generateSecret() string {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "change-me-to-a-secure-32-char-secret-key"
	}
	return base64.URLEncoding.EncodeToString(b)[:32]
}

func extractJWTSecret(envContent string) string {
	for _, line := range strings.Split(envContent, "\n") {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "JWT_SECRET_KEY=") {
			return strings.TrimSpace(strings.TrimPrefix(line, "JWT_SECRET_KEY="))
		}
	}
	return ""
}

// Pre-built community images (no Dockerfile build); tag is amd64 or arm64.
const (
	communityFrontendImage = "ghcr.io/rajanagori/nightingale_frontend_community"
	communityBackendImage  = "ghcr.io/rajanagori/nightingale_backend_community"
)

// communityArchTag maps user arch (amd, arm, or empty for host) to image tag (amd64, arm64).
func communityArchTag(arch string) (string, bool) {
	if arch == "" {
		switch runtime.GOARCH {
		case "amd64", "386":
			return "amd64", true
		case "arm64", "arm":
			return "arm64", true
		default:
			return "", false
		}
	}
	switch strings.ToLower(arch) {
	case "amd":
		return "amd64", true
	case "arm":
		return "arm64", true
	default:
		return "", false
	}
}

// writeCommunityComposeOverride writes a temporary compose override that uses pre-built community images (no build).
// Caller must remove the returned path when done.
func writeCommunityComposeOverride(root, tag string) (overridePath string, err error) {
	frontendImage := communityFrontendImage + ":" + tag
	backendImage := communityBackendImage + ":" + tag
	content := fmt.Sprintf(`# Temporary override: pre-built community images (generated by nightingale-go)
services:
  frontend:
    image: %s
    build: null
  backend:
    image: %s
    build: null
`, frontendImage, backendImage)
	f, err := os.CreateTemp(root, ".docker-compose.community.*.yaml")
	if err != nil {
		return "", err
	}
	overridePath = f.Name()
	if _, err := f.WriteString(content); err != nil {
		f.Close()
		os.Remove(overridePath)
		return "", err
	}
	if err := f.Close(); err != nil {
		os.Remove(overridePath)
		return "", err
	}
	return overridePath, nil
}

func communityStart(arch string) {
	root, ok := communityRepoRoot()
	if !ok {
		fmt.Println("❌ Run this command from the Nightingale-GUI repository root.")
		return
	}
	tag, ok := communityArchTag(arch)
	if !ok {
		if arch == "" {
			fmt.Printf("❌ Unsupported host architecture %q. Use: nightingale-go community start amd   or   community start arm\n", runtime.GOARCH)
		} else {
			fmt.Println("❌ Invalid architecture. Use 'amd', 'arm', or omit to match host.")
		}
		return
	}
	os.Setenv("NEXT_PUBLIC_EDITION", "community")
	fmt.Printf("🔄 Using pre-built community images for %s...\n", tag)
	fmt.Println("   One-click login at http://localhost:3000 after startup.")
	frontendImage := communityFrontendImage + ":" + tag
	backendImage := communityBackendImage + ":" + tag
	for _, img := range []string{frontendImage, backendImage} {
		pull := exec.Command("docker", "pull", img)
		pull.Dir = root
		pull.Stdout = os.Stdout
		pull.Stderr = os.Stderr
		if err := pull.Run(); err != nil {
			fmt.Printf("❌ Failed to pull %s: %v\n", img, err)
			return
		}
	}
	overridePath, err := writeCommunityComposeOverride(root, tag)
	if err != nil {
		fmt.Println("❌ Failed to write compose override:", err)
		return
	}
	defer os.Remove(overridePath)
	cmd := exec.Command("docker", "compose", "-f", "docker-compose.yaml", "-f", overridePath, "up", "-d", "--no-build")
	cmd.Dir = root
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		fmt.Println("❌ Failed to start:", err)
		return
	}
	fmt.Println("✅ Stack is starting. Run  nightingale-go community access  to open the console.")
}

func communityStop() {
	root, ok := communityRepoRoot()
	if !ok {
		fmt.Println("❌ Run this command from the Nightingale-GUI repository root.")
		return
	}
	cmd := exec.Command("docker", "compose", "down")
	cmd.Dir = root
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		fmt.Println("❌ Failed to stop:", err)
		return
	}
	fmt.Println("✅ Stack stopped.")
}

func communityAccess() {
	url := "http://localhost:3000"
	var openCmd *exec.Cmd
	if runtime.GOOS == "windows" {
		openCmd = exec.Command("cmd", "/C", "start", url)
	} else if runtime.GOOS == "darwin" {
		openCmd = exec.Command("open", url)
	} else {
		openCmd = exec.Command("xdg-open", url)
	}
	openCmd.Stdout = os.Stdout
	openCmd.Stderr = os.Stderr
	if err := openCmd.Run(); err != nil {
		fmt.Println("❌ Error opening browser:", err)
		fmt.Println("   Open manually:", url)
		return
	}
	fmt.Println("✅ Opening Nightingale Console (community). Use the 'Access Console' button to sign in.")
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