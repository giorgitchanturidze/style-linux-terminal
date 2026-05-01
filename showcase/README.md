# 🎨 Showcase

A minimal Node.js + Docker project that lights up multiple Starship segments at once.

```bash
cd showcase/node
```

You'll see:

- **Node.js version** — from `package.json` (needs `node` on `$PATH`)
- **Docker context** — e.g. `orbstack`, `colima`, etc., from your active Docker context
- **Git status** — branch + dirty state from this repo

## Why both files?

The `docker_context` module's default `only_with_files` setting requires a `Dockerfile` or `docker-compose.yml` in the current directory before it renders — even if a non-default Docker context is already active globally. Both files are present here so the segment shows up reliably.

## Adding more

Want to see other language modules (Rust, Python, Go, etc.)? Drop a trigger file into a new subfolder:

| Module | Trigger file |
|---|---|
| Rust | `Cargo.toml` |
| Python | `pyproject.toml` |
| Go | `go.mod` |
| Java | `pom.xml` |
| PHP | `composer.json` |

Starship only renders a language segment when its toolchain is on your `$PATH`.
