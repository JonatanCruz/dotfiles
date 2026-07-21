#!/usr/bin/env bash

# ==============================================================================
# DOTFILES · REAP STALE CLAUDE CODE SESSIONS
# ==============================================================================
# Find and terminate abandoned `claude` sessions and their MCP process trees.
#
# WHY: `claude --dangerously-skip-permissions` (or any claude session) closed
# by killing the terminal WITHOUT /exit or Ctrl+D leaves the `claude` process
# alive, holding ~200+ MCP child processes (engram, codebase-memory, serena,
# playwright, chrome-devtools, tavily, ...) and their language servers. These
# accumulate for weeks — a single 37-day zombie was found holding ~680 MB.
#
# WHAT IT DOES: lists root `claude` processes older than N days, EXCLUDING the
# current session (never suicides), and kills each full process tree by its
# root (SIGTERM → cascades to children). Dry-run by default.
#
# Usage:
#   reap-stale-claude.sh                 # dry-run, default threshold (7 days)
#   reap-stale-claude.sh --days 3        # dry-run, custom threshold
#   reap-stale-claude.sh --kill          # actually terminate stale sessions
#   reap-stale-claude.sh --kill --days 1 # terminate anything older than 1 day
#   reap-stale-claude.sh --kill --yes    # skip confirmation (for cron/health-check)
# ==============================================================================

set -euo pipefail

# Source shared library (portable: resolves symlinks so it works via Stow)
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")")" && pwd)"
# shellcheck source=./lib.sh
source "$SCRIPT_DIR/lib.sh"

# ==============================================================================
# CONFIGURATION
# ==============================================================================

DAYS=7            # default staleness threshold (days)
DO_KILL=false     # dry-run unless --kill
ASSUME_YES=false  # skip confirmation with --yes

# ==============================================================================
# ARGUMENT PARSING
# ==============================================================================

usage() {
    cat <<'EOF'
reap-stale-claude.sh — terminate abandoned Claude Code sessions

  --days N    Staleness threshold in days (default: 7)
  --kill      Actually terminate (default is dry-run)
  --yes       Skip confirmation prompt (implies non-interactive)
  --help      Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --days)  DAYS="${2:-}"; shift 2 ;;
        --kill)  DO_KILL=true; shift ;;
        --yes|-y) ASSUME_YES=true; shift ;;
        --help|-h) usage; exit 0 ;;
        *) print_error "Unknown argument: $1"; usage; exit 1 ;;
    esac
done

if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
    print_error "--days requires a non-negative integer (got: '$DAYS')"
    exit 1
fi

readonly THRESHOLD_SECS=$(( DAYS * 86400 ))

# ==============================================================================
# HELPERS
# ==============================================================================

# Elapsed seconds of a PID, portable across Linux (etimes) and macOS (etime).
# Prints an integer, or nothing if the PID is gone.
# Usage: secs=$(proc_elapsed_secs 12345)
proc_elapsed_secs() {
    local pid="$1"
    if is_linux; then
        # Linux ps supports etimes = elapsed seconds directly.
        ps -o etimes= -p "$pid" 2>/dev/null | tr -d ' '
        return
    fi
    # macOS/BSD ps: parse etime "[[DD-]HH:]MM:SS" into seconds.
    local etime
    etime="$(ps -o etime= -p "$pid" 2>/dev/null | tr -d ' ')"
    [[ -n "$etime" ]] || return 0
    local days=0 hms="$etime"
    if [[ "$etime" == *-* ]]; then
        days="${etime%%-*}"
        hms="${etime#*-}"
    fi
    local h=0 m=0 s=0
    IFS=':' read -r a b c <<< "$hms"
    if [[ -n "${c:-}" ]]; then h="$a"; m="$b"; s="$c"
    else m="$a"; s="$b"; fi
    echo $(( 10#$days*86400 + 10#$h*3600 + 10#$m*60 + 10#$s ))
}

# Total RSS (MB) of a process tree rooted at PID.
# Usage: mb=$(tree_rss_mb 12345)
tree_rss_mb() {
    local root="$1" pids
    if command -v pstree >/dev/null 2>&1; then
        pids="$(pstree -p "$root" 2>/dev/null | grep -oE '\([0-9]+\)' | tr -d '()' | sort -u | paste -sd, -)"
    else
        pids="$root"
    fi
    [[ -n "$pids" ]] || { echo 0; return; }
    ps -o rss= -p "$pids" 2>/dev/null | awk '{s+=$1} END {printf "%.0f", s/1024}'
}

# Root claude PIDs: the actual session processes, not bg helpers/daemons/forks.
# We match argv starting with "claude" and exclude bg-pty-host, daemon, spare,
# and the version-dir fork children (those have a --session-id in argv but are
# spawned BY a root; we keep only PIDs whose parent is NOT another claude).
find_root_claude_pids() {
    # Collect candidate claude PIDs (command basename == claude, or the
    # versioned binary path under .local/share/claude/versions).
    ps -eo pid,ppid,comm,args 2>/dev/null | awk '
        {
            pid=$1; ppid=$2; comm=$3;
            # Reconstruct args (fields 4..NF)
            args=""; for (i=4;i<=NF;i++) args=args (i>4?" ":"") $i;
        }
        # skip bg helpers, daemons, spares — never real sessions to reap
        args ~ /bg-pty-host|bg-spare|daemon run|statusline/ { next }
        # a root session: comm is "claude" AND not a child of another claude
        comm == "claude" { print pid" "ppid }
    '
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    require_command "ps" "ps is required to inspect processes"

    print_header "REAP STALE CLAUDE SESSIONS"

    if is_macos; then
        print_info "Platform: macOS (BSD ps — parsing etime)"
    else
        print_info "Platform: Linux (ps etimes)"
    fi
    print_info "Threshold: sessions older than ${BOLD}${DAYS} day(s)${NC}"
    if $DO_KILL; then
        print_warning "Mode: ${BOLD}KILL${NC} — stale sessions will be terminated"
    else
        print_info "Mode: dry-run (use --kill to terminate)"
    fi

    # This session's own root claude PID — NEVER reap it.
    # Walk up from $$ until we hit a process whose comm is "claude".
    local self_pid=$$ self_root=""
    while [[ "$self_pid" -gt 1 ]]; do
        local comm ppid
        comm="$(ps -o comm= -p "$self_pid" 2>/dev/null | tr -d ' ')"
        ppid="$(ps -o ppid= -p "$self_pid" 2>/dev/null | tr -d ' ')"
        if [[ "$comm" == "claude" ]]; then self_root="$self_pid"; fi
        [[ -n "$ppid" && "$ppid" != "$self_pid" ]] || break
        self_pid="$ppid"
    done
    [[ -n "$self_root" ]] && print_info "Protecting current session root: PID $self_root"

    print_section "Scanning claude sessions"

    local -a stale_pids=() stale_desc=()
    local total_mb=0 root ppid secs mb days_fmt

    while read -r root ppid; do
        [[ -n "$root" ]] || continue
        # Never reap our own session tree
        [[ "$root" == "$self_root" ]] && continue
        # Skip claude children of another claude (forks) — only reap true roots
        local pcomm
        pcomm="$(ps -o comm= -p "$ppid" 2>/dev/null | tr -d ' ')"
        [[ "$pcomm" == "claude" ]] && continue

        secs="$(proc_elapsed_secs "$root")"
        [[ -n "$secs" && "$secs" =~ ^[0-9]+$ ]] || continue

        if (( secs >= THRESHOLD_SECS )); then
            mb="$(tree_rss_mb "$root")"
            days_fmt=$(( secs / 86400 ))
            local hrs=$(( (secs % 86400) / 3600 ))
            stale_pids+=("$root")
            stale_desc+=("PID $root · age ${days_fmt}d ${hrs}h · ~${mb} MB")
            total_mb=$(( total_mb + mb ))
        fi
    done < <(find_root_claude_pids)

    if [[ ${#stale_pids[@]} -eq 0 ]]; then
        print_success "No stale claude sessions older than ${DAYS} day(s). Nothing to reap."
        exit 0
    fi

    print_warning "Found ${BOLD}${#stale_pids[@]}${NC} stale session(s), ~${BOLD}${total_mb} MB${NC} total:"
    local i
    for i in "${!stale_pids[@]}"; do
        echo "    • ${stale_desc[$i]}"
    done

    if ! $DO_KILL; then
        echo
        print_info "Dry-run — nothing killed. Re-run with ${BOLD}--kill${NC} to terminate."
        exit 0
    fi

    # Confirm unless --yes
    if ! $ASSUME_YES; then
        echo
        if ! confirm "Terminate the ${#stale_pids[@]} stale session(s) above?"; then
            print_info "Aborted. Nothing killed."
            exit 0
        fi
    fi

    print_section "Terminating"
    local killed=0
    for root in "${stale_pids[@]}"; do
        if kill -TERM "$root" 2>/dev/null; then
            print_success "SIGTERM → PID $root"
            killed=$(( killed + 1 ))
        else
            print_error "Failed to signal PID $root (already gone?)"
        fi
    done

    # Give trees a moment to unwind, then report survivors.
    sleep 3
    local survivors=0
    for root in "${stale_pids[@]}"; do
        if kill -0 "$root" 2>/dev/null; then
            survivors=$(( survivors + 1 ))
            print_warning "PID $root still alive after SIGTERM"
        fi
    done

    echo
    print_success "Reaped ${killed} session(s), freed ~${total_mb} MB."
    if (( survivors > 0 )); then
        print_warning "${survivors} survivor(s) ignored SIGTERM — re-run to send again, or kill -9 manually."
        exit 1
    fi
}

main "$@"
