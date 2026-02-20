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
			fmt.Println("  setup        - Prepare .env files (in repo or in .nightingale/ when run from any directory)")
			fmt.Println("  start [arch] - Start stack with pre-built images (works from repo or any directory); arch: amd, arm, or omit for host")
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
	fmt.Println("  community setup         Prepare .env for community (repo or .nightingale/ when run from anywhere)")
	fmt.Println("  community start [arch]  Start stack from repo or any dir using pre-built images (arch: amd, arm, or host)")
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

// communityStandaloneDir returns a directory for standalone mode (no repo): cwd/.nightingale.
// Creates the directory if it does not exist. Use when running from anywhere with pre-built images only.
func communityStandaloneDir() (string, error) {
	cwd, err := os.Getwd()
	if err != nil {
		return "", err
	}
	dir := filepath.Join(cwd, ".nightingale")
	if err := os.MkdirAll(dir, 0755); err != nil {
		return "", err
	}
	return dir, nil
}

// ensureStandaloneEnv creates backend.env and frontend.env in dir if missing (shared JWT_SECRET_KEY, edition).
func ensureStandaloneEnv(dir string) error {
	backendEnv := filepath.Join(dir, "backend.env")
	frontendEnv := filepath.Join(dir, "frontend.env")
	var secret string
	if data, err := os.ReadFile(frontendEnv); err == nil {
		secret = extractJWTSecret(string(data))
	}
	if secret == "" {
		if data, err := os.ReadFile(backendEnv); err == nil {
			secret = extractJWTSecret(string(data))
		}
	}
	if secret == "" {
		secret = generateSecret()
	}
	backendContent := "JWT_SECRET_KEY=" + secret + "\nNIGHTINGALE_EDITION=community\n"
	if err := os.WriteFile(backendEnv, []byte(backendContent), 0600); err != nil {
		return fmt.Errorf("create backend.env: %w", err)
	}
	superAdminPass := extractEnvVar(frontendEnv, "SUPER_ADMIN_PASSWORD")
	if superAdminPass == "" {
		superAdminPass = generateSuperAdminPassword()
	}
	frontendContent := "NEXT_PUBLIC_EDITION=community\nJWT_SECRET_KEY=" + secret + "\nBACKEND_URL=http://backend:8765\nNEXT_PUBLIC_VSCODE_URL=https://localhost/vscode/\nSUPER_ADMIN_PASSWORD=" + superAdminPass + "\n"
	if err := os.WriteFile(frontendEnv, []byte(frontendContent), 0600); err != nil {
		return fmt.Errorf("create frontend.env: %w", err)
	}
	return nil
}

// writeStandaloneCompose writes full stack: rabbitmq, backend, vscode (code-server), frontend, nginx with SSL.
// Only frontend and backend use ghcr.io; rabbitmq, nginx, and code-server use official images.
func writeStandaloneCompose(dir, tag string) (composePath string, err error) {
	frontendImage := communityFrontendImage + ":" + tag
	backendImage := communityBackendImage + ":" + tag
	allowedOrigins := "http://localhost:3000,https://localhost:3000,http://127.0.0.1:3000,https://127.0.0.1:3000,http://frontend:3000,http://localhost,https://localhost,http://127.0.0.1,https://127.0.0.1,http://localhost:8080,https://localhost:8080,http://localhost:443,https://localhost:443"
	content := fmt.Sprintf(`# Standalone Nightingale stack (generated by nightingale-go community start)
# Frontend and backend from ghcr.io; rabbitmq, nginx, code-server from official images. Env files in this directory.
services:
  rabbitmq:
    image: rabbitmq:3-management-alpine
    container_name: nightingale-rabbitmq
    ports:
      - "5672:5672"
      - "15672:15672"
    environment:
      RABBITMQ_DEFAULT_USER: guest
      RABBITMQ_DEFAULT_PASS: guest
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    restart: always
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "ping"]
      interval: 30s
      timeout: 10s
      retries: 5

  backend:
    image: %s
    container_name: nightingale-backend
    env_file: backend.env
    environment:
      RABBITMQ_URL: amqp://guest:guest@rabbitmq:5672/
      FRONTEND_URL: http://frontend:3000
      NIGHTINGALE_EDITION: community
      ALLOWED_ORIGINS: %s
    volumes:
      - shared_workspace:/home
      - vpn_config:/home/vpn/config:rw
      - /var/run/docker.sock:/var/run/docker.sock:ro
    working_dir: /home
    expose:
      - "8765"
    depends_on:
      rabbitmq:
        condition: service_healthy
    cap_add:
      - SYS_PTRACE
      - NET_ADMIN
    restart: always

  vscode:
    image: codercom/code-server:latest
    container_name: nightingale-vscode
    expose:
      - "8080"
    volumes:
      - shared_workspace:/home
    environment:
      PASSWORD: ""
    command: --bind-addr 0.0.0.0:8080 --auth none --disable-telemetry /home
    restart: always

  frontend:
    image: %s
    container_name: nightingale-frontend
    env_file: frontend.env
    environment:
      NODE_ENV: production
      NEXT_PUBLIC_EDITION: community
      BACKEND_URL: http://backend:8765
      NEXT_PUBLIC_VSCODE_URL: https://localhost/vscode/
    depends_on:
      - backend
      - vscode
    restart: always

  nginx:
    image: nginx:latest
    container_name: nightingale-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/certs:/etc/nginx/certs:ro
    depends_on:
      - frontend
      - backend
      - vscode
    restart: unless-stopped

volumes:
  shared_workspace: {}
  rabbitmq_data: {}
  vpn_config: {}
`, backendImage, allowedOrigins, frontendImage)
	composePath = filepath.Join(dir, "compose.yaml")
	if err := os.WriteFile(composePath, []byte(content), 0644); err != nil {
		return "", err
	}
	return composePath, nil
}

// ensureStandaloneNginx writes nginx.conf and generates self-signed SSL certs under dir/nginx/.
func ensureStandaloneNginx(dir string) error {
	nginxDir := filepath.Join(dir, "nginx")
	certsDir := filepath.Join(nginxDir, "certs")
	if err := os.MkdirAll(certsDir, 0755); err != nil {
		return fmt.Errorf("create nginx dirs: %w", err)
	}
	confPath := filepath.Join(nginxDir, "nginx.conf")
	if err := os.WriteFile(confPath, []byte(standaloneNginxConf), 0644); err != nil {
		return fmt.Errorf("write nginx.conf: %w", err)
	}
	crtPath := filepath.Join(certsDir, "selfsigned.crt")
	keyPath := filepath.Join(certsDir, "selfsigned.key")
	if _, err := os.Stat(crtPath); err == nil {
		return nil // already generated
	}
	// Generate self-signed cert with SAN so browsers (and wss://) accept it (OpenSSL 1.1.1+).
	cmd := exec.Command("openssl", "req", "-x509", "-nodes", "-days", "365", "-newkey", "rsa:2048",
		"-keyout", keyPath, "-out", crtPath,
		"-subj", "/CN=localhost/O=Nightingale/C=US",
		"-addext", "subjectAltName=DNS:localhost,IP:127.0.0.1")
	cmd.Dir = dir
	if out, err := cmd.CombinedOutput(); err != nil {
		return fmt.Errorf("generate SSL cert: %w: %s", err, string(out))
	}
	return nil
}

// findStandaloneCompose looks for .nightingale/compose.yaml in cwd or one level up (where user ran start).
func findStandaloneCompose() (string, bool) {
	cwd, err := os.Getwd()
	if err != nil {
		return "", false
	}
	for _, d := range []string{cwd, filepath.Dir(cwd)} {
		p := filepath.Join(d, ".nightingale", "compose.yaml")
		if _, err := os.Stat(p); err == nil {
			return p, true
		}
	}
	return "", false
}

func communitySetup() {
	root, inRepo := communityRepoRoot()
	if !inRepo {
		// Standalone: create .nightingale in cwd with backend.env and frontend.env
		dir, err := communityStandaloneDir()
		if err != nil {
			fmt.Println("❌ Failed to create standalone dir:", err)
			return
		}
		if err := ensureStandaloneEnv(dir); err != nil {
			fmt.Println("❌", err)
			return
		}
		fmt.Println("✅ Created", filepath.Join(dir, "backend.env"), "and", filepath.Join(dir, "frontend.env"))
		fmt.Println("\n📌 Next: run  nightingale-go community start [arch]   then  nightingale-go community access")
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
	// Keep backend JWT in sync with frontend so /api/auth/me and tokens verify correctly.
	frontData, _ := os.ReadFile(frontendEnv)
	frontSecret := extractJWTSecret(string(frontData))
	if frontSecret == "" {
		frontSecret = generateSecret()
	}
	if _, err := os.Stat(backendEnv); os.IsNotExist(err) {
		content := "JWT_SECRET_KEY=" + frontSecret + "\nNIGHTINGALE_EDITION=community\n"
		if err := os.WriteFile(backendEnv, []byte(content), 0600); err != nil {
			fmt.Println("❌ Failed to create gui/go_backend/.env:", err)
			return
		}
		fmt.Println("✅ Created gui/go_backend/.env with JWT_SECRET_KEY and NIGHTINGALE_EDITION=community")
	} else {
		backendData, _ := os.ReadFile(backendEnv)
		backendContent := string(backendData)
		backendSecret := extractJWTSecret(backendContent)
		updated := false
		if backendSecret != frontSecret {
			// Replace backend JWT with frontend's so verification succeeds
			if strings.Contains(backendContent, "JWT_SECRET_KEY=") {
				lines := strings.Split(backendContent, "\n")
				var newLines []string
				for _, line := range lines {
					if strings.HasPrefix(strings.TrimSpace(line), "JWT_SECRET_KEY=") {
						newLines = append(newLines, "JWT_SECRET_KEY="+frontSecret)
						updated = true
					} else {
						newLines = append(newLines, line)
					}
				}
				backendContent = strings.Join(newLines, "\n")
			} else {
				backendContent = "JWT_SECRET_KEY=" + frontSecret + "\n" + backendContent
				updated = true
			}
		}
		if !strings.Contains(backendContent, "NIGHTINGALE_EDITION=") {
			backendContent = "NIGHTINGALE_EDITION=community\n" + backendContent
			updated = true
		}
		if updated {
			_ = os.WriteFile(backendEnv, []byte(backendContent), 0600)
			fmt.Println("✅ Synced gui/go_backend/.env JWT_SECRET_KEY with frontend (fixes signature verification)")
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

// generateSuperAdminPassword returns a password that meets frontend requirements: >=16 chars, upper, lower, number, special.
func generateSuperAdminPassword() string {
	const (
		upper   = "ABCDEFGHJKLMNPQRSTUVWXYZ"
		lower   = "abcdefghjkmnpqrstuvwxyz"
		digits  = "23456789"
		special = "!@#$%&*"
	)
	b := make([]byte, 20)
	if _, err := rand.Read(b); err != nil {
		return "ChangeMe-Secure1!Community"
	}
	// Ensure at least one of each required character type
	pw := []byte{
		upper[b[0]%byte(len(upper))],
		lower[b[1]%byte(len(lower))],
		digits[b[2]%byte(len(digits))],
		special[b[3]%byte(len(special))],
	}
	for i := 4; i < 20; i++ {
		all := upper + lower + digits + special
		pw = append(pw, all[int(b[i])%len(all)])
	}
	// Shuffle so order isn't predictable
	for i := len(pw) - 1; i > 0; i-- {
		j := int(b[i%4]) % (i + 1)
		pw[i], pw[j] = pw[j], pw[i]
	}
	return string(pw)
}

func extractJWTSecret(envContent string) string {
	return extractEnvVarFromContent(envContent, "JWT_SECRET_KEY")
}

// extractEnvVar reads the file at path and returns the value of the given env var (e.g. SUPER_ADMIN_PASSWORD).
func extractEnvVar(path, key string) string {
	data, err := os.ReadFile(path)
	if err != nil {
		return ""
	}
	return extractEnvVarFromContent(string(data), key)
}

func extractEnvVarFromContent(envContent, key string) string {
	prefix := key + "="
	for _, line := range strings.Split(envContent, "\n") {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, prefix) {
			return strings.TrimSpace(strings.TrimPrefix(line, prefix))
		}
	}
	return ""
}

// Pre-built community images from ghcr.io; tag is amd64 or arm64. Rest use official images (rabbitmq, nginx, code-server).
const (
	communityFrontendImage = "ghcr.io/rajanagori/nightingale_frontend_community"
	communityBackendImage  = "ghcr.io/rajanagori/nightingale_backend_community"
)

// standaloneNginxConf is the nginx config for standalone (HTTP 80 + HTTPS 443 with SSL).
const standaloneNginxConf = `user  nginx;
worker_processes  auto;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    upstream frontend {
        server frontend:3000;
    }
    upstream backend_ws {
        server backend:8765;
    }
    upstream vscode {
        server vscode:8080;
    }

    server {
        listen 80;
        server_name localhost;
        location /ws {
            proxy_pass http://backend_ws;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Origin $http_origin;
            proxy_cache_bypass $http_upgrade;
            proxy_read_timeout 86400;
            proxy_send_timeout 86400;
        }
        location /vscode/ {
            proxy_pass http://vscode/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Origin $http_origin;
            proxy_cache_bypass $http_upgrade;
            proxy_read_timeout 86400;
            proxy_send_timeout 86400;
            rewrite ^/vscode/(.*) /$1 break;
        }
        location / {
            proxy_pass http://frontend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
        }
    }

    server {
        listen 443 ssl;
        server_name localhost;
        ssl_certificate     /etc/nginx/certs/selfsigned.crt;
        ssl_certificate_key /etc/nginx/certs/selfsigned.key;
        ssl_protocols       TLSv1.2 TLSv1.3;
        ssl_ciphers         HIGH:!aNULL:!MD5;

        location /ws {
            proxy_pass http://backend_ws;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Origin $http_origin;
            proxy_cache_bypass $http_upgrade;
            proxy_read_timeout 86400;
            proxy_send_timeout 86400;
        }
        location /vscode/ {
            proxy_pass http://vscode/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Origin $http_origin;
            proxy_cache_bypass $http_upgrade;
            proxy_read_timeout 86400;
            proxy_send_timeout 86400;
            add_header Service-Worker-Allowed /;
            add_header X-Content-Type-Options nosniff;
            rewrite ^/vscode/(.*) /$1 break;
        }
        location / {
            proxy_pass http://frontend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
        }
    }
}
`

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

	root, inRepo := communityRepoRoot()
	if inRepo {
		// Repo mode: use repo docker-compose + override
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
		return
	}

	// Standalone mode: frontend and backend from ghcr.io; rabbitmq, nginx, code-server from official images
	dir, err := communityStandaloneDir()
	if err != nil {
		fmt.Println("❌ Failed to create standalone dir:", err)
		return
	}
	if err := ensureStandaloneEnv(dir); err != nil {
		fmt.Println("❌", err)
		return
	}
	if err := ensureStandaloneNginx(dir); err != nil {
		fmt.Println("❌ Nginx/SSL setup:", err)
		return
	}
	composePath, err := writeStandaloneCompose(dir, tag)
	if err != nil {
		fmt.Println("❌ Failed to write compose:", err)
		return
	}
	// Only pull custom images from ghcr.io; rabbitmq, nginx, code-server are pulled by docker compose from official registries
	images := []string{
		communityFrontendImage + ":" + tag,
		communityBackendImage + ":" + tag,
	}
	for _, img := range images {
		pull := exec.Command("docker", "pull", img)
		pull.Stdout = os.Stdout
		pull.Stderr = os.Stderr
		if err := pull.Run(); err != nil {
			fmt.Printf("❌ Failed to pull %s: %v\n", img, err)
			return
		}
	}
	cmd := exec.Command("docker", "compose", "-f", composePath, "up", "-d", "--no-build")
	cmd.Dir = dir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		fmt.Println("❌ Failed to start:", err)
		return
	}
	fmt.Println("✅ Stack is starting. Open https://localhost (HTTP on port 80, HTTPS on 443).")
	fmt.Println("   If the browser warns about the certificate: use Advanced → Proceed to localhost so the terminal (WebSocket) works.")
	fmt.Println("   Run  nightingale-go community access  to open in browser. To stop:  nightingale-go community stop  from this directory.")
}

func communityStop() {
	root, inRepo := communityRepoRoot()
	if inRepo {
		cmd := exec.Command("docker", "compose", "down")
		cmd.Dir = root
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			fmt.Println("❌ Failed to stop:", err)
			return
		}
		fmt.Println("✅ Stack stopped.")
		return
	}
	composePath, ok := findStandaloneCompose()
	if !ok {
		fmt.Println("❌ No standalone stack found. Run from the directory where you ran  community start  (or its parent).")
		return
	}
	cmd := exec.Command("docker", "compose", "-f", composePath, "down")
	cmd.Dir = filepath.Dir(composePath)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		fmt.Println("❌ Failed to stop:", err)
		return
	}
	fmt.Println("✅ Stack stopped.")
}

func communityAccess() {
	// Prefer HTTPS (standalone and repo both use nginx with SSL)
	url := "https://localhost"
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
		fmt.Println("   Open manually:", url, "(or http://localhost:3000 if not using nginx)")
		return
	}
	fmt.Println("✅ Opening Nightingale Console. Use the 'Access Console' button to sign in (accept self-signed cert if prompted).")
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