# plural-core

Shared Go library providing the core backend for [Plural](https://github.com/zhubert/plural) (TUI) and [Plural Agent](https://github.com/zhubert/plural-agent) (headless daemon).

## Overview

plural-core handles the backend concerns shared across Plural applications:

- **Claude Code CLI management** — process lifecycle, message streaming, and auto-recovery
- **Session isolation** — each session runs in its own git worktree for conflict-free parallel work
- **Permission system** — MCP-based permission prompts routed through unix sockets
- **Git operations** — worktree creation, branching, merging, and GitHub PR integration
- **Issue tracking** — pluggable providers for GitHub, Asana, and Linear
- **Configuration** — thread-safe, JSON-based config with XDG path support

## Installation

```bash
go get github.com/zhubert/plural-core
```

Requires Go 1.25+.

## Packages

| Package | Description |
|---------|-------------|
| `claude` | Claude Code CLI wrapper — Runner, streaming, permission channels |
| `mcp` | Model Context Protocol server over JSON-RPC 2.0 / unix sockets |
| `git` | Git operations — worktrees, branches, merges, GitHub PRs via `gh` |
| `config` | Configuration loading/saving with thread-safe access |
| `manager` | Session lifecycle management and state coordination |
| `session` | Session creation with isolated git worktrees |
| `issues` | Issue provider interface (GitHub, Asana, Linear) |
| `logger` | Structured logging via `slog` |
| `paths` | XDG-compliant path resolution |
| `process` | Docker/container utilities |
| `exec` | Testable command execution abstraction |
| `cli` | CLI tool prerequisite checks (claude, git, gh) |

## Usage

```go
import "github.com/zhubert/plural-core/claude"

runner := claude.New(sessionID, workingDir, repoPath, sessionStarted, initialMessages)
responseChan := runner.Send(ctx, "Hello, Claude!")
for chunk := range responseChan {
    if chunk.Error != nil {
        log.Fatal(chunk.Error)
    }
    fmt.Print(chunk.Content)
}
defer runner.Stop()
```

## Development

```bash
make test    # run all tests
make clean   # clear build/test cache
```

## Architecture

```
Claude CLI ──→ MCP Server (subprocess) ──→ Unix Socket ──→ Consumer (TUI / Agent)
               (--permission-prompt-tool)    (/tmp/plural-<id>.sock)
```

Each session gets its own git worktree under `~/.plural/worktrees/<uuid>/`, keeping parallel Claude conversations fully isolated.

## License

[MIT](LICENSE)
