# dev-env CI base image

A Docker image that reproduces the **exact same runtimes** as the rest of this repo:
- Node / Python / Java pinned in `runtime/.tool-versions` (installed via asdf)
- .NET pinned in `runtime/global.json`
- Rust pinned in `runtime/rust-toolchain.toml`
- CLI tools: ripgrep, bat, fd, delta, jq, gh, eza

This guarantees CI runs on the same versions every developer has locally.

## Build

From the repo root:

```bash
docker build -f docker/Dockerfile -t dev-env-ci:latest .
# or use the helper:
bash docker/build.sh dev-env-ci:latest
```

## Run a one-off task

```bash
docker run --rm -v "$PWD:/workspace" -w /workspace dev-env-ci:latest bash -c 'node -v && go version'
```

## Use in CI (GitHub Actions)

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/your-org/dev-env-ci:latest
    steps:
      - uses: actions/checkout@v4
      - run: node -v && python -V && java -version && dotnet --version && go version && rustc --version
      - run: make ci
```

## Publish — automated (recommended)

A GitHub Actions workflow lives at
[`.github/workflows/build-ci-image.yml`](../.github/workflows/build-ci-image.yml).
It builds and pushes the image to **ghcr.io** automatically:

- **On push** to `main`/`master` whenever a runtime pin changes
  (`runtime/.tool-versions`, `runtime/global.json`, `runtime/rust-toolchain.toml`,
  `runtime/.node-version`), or the `docker/` files / workflow itself change.
- **Weekly** (Mondays 03:17 UTC) so the `ubuntu:22.04` base + apt packages stay patched
  even when our pins don't move.
- **Manual** via `workflow_dispatch`.

It publishes three tags: `latest`, a date tag (`YYYYMMDD`), and a commit-short-SHA tag.
No secret setup needed — it uses the built-in `GITHUB_TOKEN` (the repo already has
`packages: write`). The image is pushed under the repo's own namespace:
`ghcr.io/<owner>/<repo>/dev-env-ci`. To publish under a different org, edit the
`IMAGE` env var in the workflow.

Consume it in CI exactly as shown in the "Use in CI" section above — just point
`image:` at `ghcr.io/<owner>/<repo>/dev-env-ci:latest`.

## Publish — manual (optional)

```bash
docker tag dev-env-ci:latest ghcr.io/your-org/dev-env-ci:latest
docker push ghcr.io/your-org/dev-env-ci:latest
```

Keep the image build in CI (or a scheduled workflow) so it tracks `runtime/.tool-versions` changes.
