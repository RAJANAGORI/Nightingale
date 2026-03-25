# Contributing to Nightingale

Welcome! Your contributions help make Nightingale a powerful, secure toolkit. Please take a moment to review these guidelines.

## How to Get Involved

- Suggest features, report bugs, or request enhancements.
- Submit pull requests for new tools, bug fixes, or documentation improvements.
- Help test and review new Docker images.

## Setup & Testing

1. Fork the repo and clone locally.
1. Build and run Nightingale:

```bash
# Build default image from repo root
docker build -t nightingale:local .

# Build ARM64 image
docker buildx build --platform linux/arm64 -t nightingale:arm64-local architecture/arm64/v8

# Run local image
docker run --rm -it -p 8080:7681 nightingale:local ttyd -p 7681 bash
```

Expected output includes successful Docker build layers and a running container where `http://localhost:8080` serves the web terminal.

1. Validate key paths before opening a PR:

```bash
# Confirm Go app builds
cd nightingale-go && go build ./...

# Return to repo root and run security scan workflow locally if available,
# or ensure CI passes on your branch.
```

1. Follow security best practices when adding tools or modifying scripts.

## Guidelines

- **Security**: No hardcoded credentials, open ports, or insecure settings.
- **Testing**: Test all changes inside the Docker environment.
- **Documentation**: Update `README.md` and related docs for any new features.
- **Style**: Follow Dockerfile and shell scripting best practices.
- **Pull Requests**: Use the PR template and fill out all relevant fields.
- **Scope**: Keep PRs focused; separate tool additions from refactoring when possible.

## Reporting Bugs or Vulnerabilities

- For regular bugs, open an issue.
- For security issues, email [raja.nagori@owasp.org].

## Code of Conduct

We follow the [Contributor Covenant](CODE_OF_CONDUCT.md). Please be welcoming, inclusive, and respectful.

---

Thank you for contributing!
