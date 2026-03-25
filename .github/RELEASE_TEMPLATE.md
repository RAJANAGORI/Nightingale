# Release Notes Template

## What changed

- TBD

## Who benefits

- TBD

## Upgrade / pull command

Upgrade Nightingale to the latest stable version.

```bash
docker pull ghcr.io/rajanagori/nightingale:stable
```

## Verification

Run the image and verify that `http://localhost:8080` opens the terminal UI.

```bash
docker run --rm -it -p 8080:7681 ghcr.io/rajanagori/nightingale:stable ttyd -p 7681 bash
```
