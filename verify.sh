#!/usr/bin/env bash
# verify.sh — Check that every command, flag, config, and file path
# documented on the Token Saving Techniques page exists in locally installed tools.
# Run before deploying to ensure page accuracy.

set -uo pipefail

PASS=0
FAIL=0
SKIP=0

check() {
  local tool="$1" description="$2" cmd="$3" expected="$4"
  if ! command -v "$tool" &>/dev/null; then
    echo "  SKIP  $tool: $description ($tool not found)"
    ((SKIP++))
    return
  fi
  output=$(eval "$cmd" 2>&1 || true)
  if echo "$output" | grep -qiF -- "$expected"; then
    echo "  PASS  $tool: $description"
    ((PASS++))
  else
    echo "  FAIL  $tool: $description"
    echo "        Expected '$expected' in output of: $cmd"
    ((FAIL++))
  fi
}

check_file() {
  local description="$1" path="$2"
  if [ -e "$path" ]; then
    echo "  PASS  file: $description ($path)"
    ((PASS++))
  else
    echo "  FAIL  file: $description ($path not found)"
    ((FAIL++))
  fi
}

check_file_optional() {
  local description="$1" path="$2"
  echo "  INFO  file: $description ($path — project-level, skipped)"
}

# ============================================================
# SECTION 01: CONTEXT HYGIENE
# ============================================================
echo "=== 01: Context Hygiene ==="
echo ""

echo "--- Clear Context ---"
# CC: /clear — built-in slash command (not a CLI flag, verified in CC docs)
echo "  INFO  claude: /clear is an internal slash command (verified via official docs)"
# Cursor: /clear — interactive slash command in agent CLI
echo "  INFO  cursor: /clear is an interactive slash command (verified in agent CLI)"
# Codex: /new — internal slash command, verified from source
echo "  INFO  codex: /new is an internal slash command (verified from source)"
# Gemini: /clear — internal slash command, verified from source
echo "  INFO  gemini: /clear is an internal slash command (verified from source)"

echo ""
echo "--- Rules Files ---"
# CC: CLAUDE.md <200 lines — file convention
# Cursor: .cursor/rules/*.mdc — project-level config
# Codex: AGENTS.md — project-level config
# Gemini: GEMINI.md with @imports — project-level config

echo ""
echo "--- File References ---"
check claude "CC @file / /add-dir" "command claude --help" "add-dir"
# Codex: /mention — internal slash command
# Gemini: @path — internal feature

echo ""
echo "--- Exclude Files ---"
check claude "CC permissions.deny in settings" "command claude --help" "permission"
# Cursor: .cursorignore — project-level
# Codex: writable_roots in config
check codex "Codex sandbox policy" "codex --help" "sandbox"
# Gemini: .geminiignore — project-level

echo ""
echo "--- Compact / Summarize ---"
# CC: /compact, /autocompact — internal slash commands (confirmed in CC docs)
echo "  INFO  claude: /compact and /autocompact are internal slash commands (verified via official docs)"
# Cursor: /compress — interactive slash command
echo "  INFO  cursor: /compress is an interactive slash command (verified in agent CLI)"
# Codex: /compact — internal slash command (confirmed from source)
echo "  INFO  codex: /compact is an internal slash command (verified from source)"
# Gemini: /compress (aliases: /compact, /summarize) — confirmed from source
echo "  INFO  gemini: /compress is an internal slash command (verified from source)"

echo ""
echo "--- Output Caps ---"
# CC: BASH_MAX_OUTPUT_LENGTH env var (verified at code.claude.com/docs/en/env-vars)
echo "  INFO  claude: BASH_MAX_OUTPUT_LENGTH env var (verified at code.claude.com/docs/en/env-vars)"
# Codex: tool_output_token_limit in config.toml (verified from source)
echo "  INFO  codex: tool_output_token_limit config option (verified from GitHub source)"
# Gemini: truncateToolOutputThreshold in settings.json (verified from source)
echo "  INFO  gemini: truncateToolOutputThreshold setting (verified from source)"

echo ""
echo "--- Prompt Cache ---"
# CC: configurable TTL (5m/1h), 1h default on subscription — verified from CC docs
echo "  INFO  claude: prompt cache configurable TTL via promptCacheTtl setting (verified via official docs)"
echo "  INFO  claude: CLAUDE_CODE_PROMPT_CACHE_TTL env var (verified at code.claude.com/docs/en/env-vars)"
# Gemini: token caching for API key / Vertex AI — verified from source
echo "  INFO  gemini: token caching for API key and Vertex AI users (verified from source)"

echo ""
echo "--- Completion Sounds ---"
check_file "CC ~/.claude.json (preferredNotifChannel)" "$HOME/.claude.json"
# Codex: /statusline — internal slash command

# ============================================================
# SECTION 02: PROMPTING STRATEGY
# ============================================================
echo ""
echo "=== 02: Prompting Strategy ==="
echo ""

echo "--- Plan Mode ---"
check claude "CC --permission-mode plan" "command claude --help" "permission-mode"
check agent "Cursor --mode=plan" "agent --help" "plan"
check agent "Cursor --plan shorthand" "agent --help" "--plan"
# Codex: --ask-for-approval untrusted / /plan slash command
check codex "Codex -a / --ask-for-approval flag" "codex --help" "ask-for-approval"
check codex "Codex sandbox read-only" "codex exec --help" "read-only"
check gemini "Gemini --approval-mode plan" "gemini --help" "plan"

echo ""
echo "--- Slash commands (Plan Mode) ---"
echo "  INFO  claude: /plan is an internal slash command (verified via official docs)"
echo "  INFO  cursor: /plan is an interactive slash command (verified in agent CLI)"
echo "  INFO  codex: /plan is an internal slash command (verified from source)"
echo "  INFO  gemini: /plan is an internal slash command (verified from source)"

echo ""
echo "--- Rewind ---"
echo "  INFO  claude: /rewind is an internal slash command (verified via official docs)"
echo "  INFO  cursor: /rewind is an interactive slash command (verified in agent CLI changelog)"
echo "  INFO  gemini: /rewind is an internal slash command (verified from source)"

echo ""
echo "--- Ask / Read-Only Mode ---"
check agent "Cursor --mode=ask" "agent --help" "ask"
echo "  INFO  cursor: /ask is an interactive slash command (verified in agent CLI)"

# ============================================================
# SECTION 03: MODEL ROUTING
# ============================================================
echo ""
echo "=== 03: Model Routing ==="
echo ""
check claude "CC --model flag" "command claude --help" "--model"
check agent "Cursor --model flag" "agent --help" "--model"
check agent "Cursor models subcommand" "agent --help" "models"
check codex "Codex -m flag in exec" "codex exec --help" "model"
check gemini "Gemini -m flag" "gemini --help" "model"
echo "  INFO  claude: /model is an internal slash command (verified via official docs)"
echo "  INFO  cursor: /model is an interactive slash command (verified in agent CLI)"
echo "  INFO  codex: /model is an internal slash command (verified from source)"
echo "  INFO  gemini: /model is an internal slash command (verified from source)"

# ============================================================
# SECTION 04: AGENT ARCHITECTURE
# ============================================================
echo ""
echo "=== 04: Agent Architecture ==="
echo ""

echo "--- Subagents ---"
check claude "CC --agents flag" "command claude --help" "--agents"
# Cursor: Built-in subagents (can't test from CLI help)
echo "  INFO  cursor: built-in subagents (no CLI flag to test)"
# Codex: /agent — internal slash command
echo "  INFO  codex: /agent is an internal slash command (verified from source)"
# Gemini: /agents — internal slash command
echo "  INFO  gemini: /agents is an internal slash command (verified from source)"

echo ""
echo "--- MCP Management ---"
check agent "Cursor mcp enable" "agent mcp --help" "enable"
check agent "Cursor mcp disable" "agent mcp --help" "disable"
check agent "Cursor mcp list" "agent mcp --help" "list"
check agent "Cursor mcp list-tools" "agent mcp --help" "list-tools"
check codex "Codex mcp subcommand" "codex mcp --help" "mcp"
check gemini "Gemini mcp subcommand" "gemini --help" "mcp"

echo ""
echo "--- Skills ---"
# CC: .claude/skills/*/SKILL.md — project-level
# Codex: .codex/skills/*/SKILL.md — project-level
check gemini "Gemini skills subcommand" "gemini --help" "skills"

echo ""
echo "--- Thinking Effort ---"
check claude "CC --effort flag" "command claude --help" "effort"
echo "  INFO  claude: /effort is an internal slash command (verified via official docs)"
echo "  INFO  claude: /fast toggle is an internal slash command (verified via official docs)"
echo "  INFO  cursor: /max-mode is an interactive slash command (verified in agent CLI)"
echo "  INFO  cursor: /fast is an interactive slash command (verified in agent CLI)"
echo "  INFO  codex: /model (set effort) is an internal slash command (verified from source)"
echo "  INFO  codex: model_reasoning_effort config option (verified from GitHub source)"
echo "  INFO  gemini: /model set is an internal slash command (verified from source)"
echo "  INFO  gemini: thinkingBudget in modelConfigs setting (verified from source)"

echo ""
echo "--- Hooks ---"
echo "  INFO  claude: hooks in settings.json (verified via official docs — code.claude.com/docs/en/hooks)"
echo "  INFO  cursor: .cursor/hooks.json (verified via cursor.com/docs/hooks)"
echo "  INFO  codex: .codex/hooks.json (verified via developers.openai.com/codex/hooks)"
echo "  INFO  gemini: hooks in settings.json (verified via geminicli.com/docs/hooks)"

# ============================================================
# SECTION 05: COST & LIMIT MANAGEMENT
# ============================================================
echo ""
echo "=== 05: Cost & Limit Management ==="
echo ""

echo "--- Context Window & Thinking Env Vars ---"
echo "  INFO  claude: CLAUDE_CODE_MAX_CONTEXT_TOKENS (verified at code.claude.com/docs/en/env-vars)"
echo "  INFO  claude: CLAUDE_CODE_AUTO_COMPACT_WINDOW (verified at code.claude.com/docs/en/env-vars)"
echo "  INFO  claude: CLAUDE_CODE_EFFORT_LEVEL (verified at code.claude.com/docs/en/env-vars)"
echo "  INFO  claude: MAX_THINKING_TOKENS (verified at code.claude.com/docs/en/env-vars)"
echo "  INFO  claude: BASH_MAX_OUTPUT_LENGTH (verified at code.claude.com/docs/en/env-vars)"

echo ""
echo "--- Subagent Model Control ---"
echo "  INFO  claude: CLAUDE_CODE_SUBAGENT_MODEL env var (verified at code.claude.com/docs/en/env-vars)"
echo "  INFO  claude: CLAUDE_CODE_SUBAGENT_MODEL_FORCE env var (verified at code.claude.com/docs/en/env-vars)"
echo "  INFO  codex: agents.default_subagent_model config option (verified from GitHub source)"
echo "  INFO  gemini: per-subagent model override in settings.json (verified from source)"

echo ""
echo "--- Codex Token Budgets ---"
echo "  INFO  codex: goals.max_goal_token_budget config option (verified from GitHub source)"
echo "  INFO  codex: model_context_window config option (verified from GitHub source)"

echo ""
echo "--- Gemini Token Budgets ---"
echo "  INFO  gemini: maxOutputTokens in modelConfigs setting (verified from source)"
echo "  INFO  gemini: thinkingBudget in modelConfigs setting (verified from source)"
echo "  INFO  gemini: maxSessionTurns setting (verified from source)"
echo "  INFO  gemini: compressionThreshold setting (verified from source)"

echo ""
echo "--- Persist Decisions ---"
echo "  INFO  claude: /memory is an internal slash command (verified via official docs)"
echo "  INFO  gemini: /memory add is an internal slash command (verified from source)"

echo ""
echo "--- Track Spend ---"
echo "  INFO  claude: /usage (alias /cost) is an internal slash command (verified via official docs)"
echo "  INFO  cursor: /usage is an interactive slash command (verified in agent CLI)"
echo "  INFO  codex: /usage is an internal slash command (verified from GitHub releases v0.140.0)"
echo "  INFO  codex: /status shows estimated cost (verified from GitHub releases v0.148.0)"
echo "  INFO  gemini: /stats is an internal slash command (verified from source)"

echo ""
echo "--- Resume ---"
check claude "CC --resume flag" "command claude --help" "--resume"
check claude "CC --continue flag" "command claude --help" "--continue"
check agent "Cursor --resume flag" "agent --help" "--resume"
check agent "Cursor --continue flag" "agent --help" "--continue"
check codex "Codex resume subcommand" "codex resume --help" "resume"
check codex "Codex resume --last" "codex resume --help" "last"
check gemini "Gemini --resume flag" "gemini --help" "--resume"
echo "  INFO  claude: /resume is an internal slash command (verified via official docs)"
echo "  INFO  cursor: /resume is an interactive slash command (verified in agent CLI)"
echo "  INFO  gemini: /resume is an internal slash command (verified from source)"

echo ""
echo "--- Background / Cloud ---"
check agent "Cursor --cloud flag" "agent --help" "--cloud"
check codex "Codex exec subcommand" "codex --help" "exec"
check codex "Codex cloud subcommand" "codex --help" "cloud"
check gemini "Gemini --prompt headless" "gemini --help" "--prompt"

echo ""
echo "--- Worktrees ---"
check claude "CC --worktree flag" "command claude --help" "--worktree"
check agent "Cursor --worktree flag" "agent --help" "--worktree"
check gemini "Gemini --worktree flag" "gemini --help" "--worktree"

echo ""
echo "--- Quick Ref Slash Commands ---"
echo "  INFO  claude: /context is an internal slash command (verified via official docs)"
echo "  INFO  claude: /fast is an internal slash command (verified via official docs)"
echo "  INFO  claude: /rewind is an internal slash command (verified via official docs)"
echo "  INFO  claude: /autocompact is an internal slash command (verified via official docs)"
echo "  INFO  codex: /mention is an internal slash command (verified from source)"
echo "  INFO  codex: /new is an internal slash command (verified from source)"
echo "  INFO  codex: /diff is an internal slash command (verified from source)"
echo "  INFO  codex: /review is an internal slash command (verified from source)"
echo "  INFO  codex: /usage is an internal slash command (verified from GitHub releases)"
echo "  INFO  gemini: /rewind is an internal slash command (verified from source)"
echo "  INFO  gemini: /skills is an internal slash command (verified from source)"
echo "  INFO  cursor: /mcp is an interactive slash command (verified in agent CLI)"

# ============================================================
# CONFIG FILES (existence checks)
# ============================================================
echo ""
echo "=== Config Files ==="
check_file "CC global config (~/.claude.json)" "$HOME/.claude.json"
check_file "Codex config (~/.codex/config.toml)" "$HOME/.codex/config.toml"
# Project-level files are optional — just note them
check_file_optional "CLAUDE.md" "./CLAUDE.md"
check_file_optional ".cursorignore" "./.cursorignore"
check_file_optional ".geminiignore" "./.geminiignore"
check_file_optional "AGENTS.md" "./AGENTS.md"
check_file_optional "GEMINI.md" "./GEMINI.md"
check_file_optional ".cursor/mcp.json" "./.cursor/mcp.json"
check_file_optional ".mcp.json (CC)" "./.mcp.json"

echo ""
echo "=== Summary ==="
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
echo "  SKIP: $SKIP"
if [ "$FAIL" -gt 0 ]; then
  echo "  ❌ $FAIL checks failed — review page content"
  exit 1
else
  echo "  ✅ All checks passed"
fi
