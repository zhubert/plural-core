# plural-core

Shared Go library providing the core backend for [Plural](https://github.com/zhubert/plural) (TUI) and [Plural Agent](https://github.com/zhubert/plural-agent) (headless daemon).

## Quick Reference

```bash
make test    # run all tests (no cache)
make clean   # clear Go build/test cache
```

## Project Structure

```
claude/    - Claude Code CLI process wrapper (Runner, streaming, permissions)
mcp/       - Model Context Protocol server (JSON-RPC 2.0, unix sockets)
git/       - Git operations (worktrees, branches, merges, GitHub PRs)
config/    - JSON-based configuration with thread-safe access
manager/   - Session lifecycle management and state coordination
session/   - Session creation with git worktrees
issues/    - Issue provider interface (GitHub, Asana, Linear)
logger/    - Structured logging via slog
paths/     - XDG-compliant path resolution
process/   - Docker/container utilities
exec/      - Command execution abstraction for testability
cli/       - CLI tool prerequisite checks
```

## Conventions

- **Dependency injection** everywhere: `CommandExecutor` interface wraps `os/exec`, `RunnerFactory` for session creation, pluggable issue providers.
- **Thread safety**: state structs use `sync.RWMutex`, channels for concurrency, `context` for cancellation.
- **Testing**: every package has `*_test.go` files and a `testmain_test.go`. Use mock executors and mock runners — never shell out in tests.
- **Minimal dependencies**: only `github.com/google/uuid` beyond the standard library. Prefer stdlib.
- **Error handling**: wrap errors with `fmt.Errorf("context: %w", err)`. No panics.
- **No global state**: pass dependencies explicitly via constructors.

## Key Patterns

The MCP permission flow: Claude CLI -> MCP subprocess -> unix socket -> TUI modal. Permission requests/responses flow through channels with a 5-minute timeout.

Sessions each get an isolated git worktree stored under `~/.plural/worktrees/<uuid>/`.

The `claude.Runner` streams responses via `chan ResponseChunk` — callers range over the channel until `Done` is true.
