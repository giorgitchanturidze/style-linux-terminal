# 🎨 Showcase

A minimal Node.js + Docker project that lights up multiple Starship segments at once.

![Showcase Screenshot](./screenshot.png)

```bash
cd showcase
```

You'll see:

- **Node.js version** — from `package.json` (needs `node` on `$PATH`)
- **Docker context** — e.g. `orbstack`, `colima`, etc., from your active Docker context
- **Git status** — branch + dirty state from this repo

## Why both Docker files?

The `docker_context` module's default `only_with_files` setting requires a `Dockerfile` or `docker-compose.yml` in the current directory before it renders — even if a non-default Docker context is already active globally. Both files are present here so the segment shows up reliably.

> 💡 If your only Docker context is `default`, the segment stays hidden by design. To make it appear, either create a real non-default context (`docker context create demo --docker host=unix:///var/run/docker.sock && docker context use demo`) or set `DOCKER_CONTEXT=demo` for a one-off demo.

## Adding more

Want to see other language modules (Rust, Python, Go, etc.)? Drop a trigger file alongside these:

| Module | Trigger file |
|---|---|
| Rust | `Cargo.toml` |
| Python | `pyproject.toml` |
| Go | `go.mod` |
| Java | `pom.xml` |
| PHP | `composer.json` |

Starship only renders a language segment when its toolchain is on your `$PATH`.
