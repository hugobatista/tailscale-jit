#!/usr/bin/env bash
set -euo pipefail

APP_NAME="$(basename "$PWD")-secrets"

color_on=""
color_off=""
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
	color_on="$(tput setaf 6)"
	color_off="$(tput sgr0)"
fi

info() {
	printf '%s%s%s\n' "$color_on" "$*" "$color_off"
}

show_help() {
	cat <<'EOF'
run-act.sh

Run GitHub Actions locally with act, backed by secrets stored in secret-tool.

Usage:
	./run-act.sh [--app APP_NAME] [act args...]
	./run-act.sh --help

Behavior:
	- Looks up secrets by app name (defaults to current folder name + "-secrets").
	- If missing, prompts you to paste secrets content and stores it.
	- Ensures ./bin/act exists, installing it if needed.
	- Executes ./bin/act with --secret-file sourced from secret-tool.

Examples:
	./run-act.sh --app myproject-secrets workflow_dispatch -j my_job_name -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest
	./run-act.sh workflow_dispatch -j my_job_name -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest
	./run-act.sh push -j my_job_name
	./run-act.sh -l
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	show_help
	exit 0
fi

if [[ "${1:-}" == "--app" ]]; then
	if [[ -z "${2:-}" ]]; then
		echo "Error: --app requires a value." >&2
		exit 1
	fi
	APP_NAME="$2"
	shift 2
fi

info "Retrieving secrets for app '$APP_NAME'."
if secrets_input="$(secret-tool lookup app "$APP_NAME" 2>/dev/null)"; then
	info "Secrets found in secret-tool."
else
	info "No secrets found for app '$APP_NAME'."
	info "Paste the secrets content, then press Ctrl-D:"
	secrets_input="$(cat)"
	if [[ -z "$secrets_input" ]]; then
		echo "Error: no secrets provided." >&2
		exit 1
	fi
	info "Storing secrets in secret-tool."
	printf '%s' "$secrets_input" | secret-tool store app "$APP_NAME" --label="$APP_NAME"
fi

if [[ ! -x "./bin/act" ]]; then
	info "act not found at ./bin/act; installing..."
	curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
else
	info "act found at ./bin/act."
fi

info "Running act with args: $*"
./bin/act --secret-file <(printf '%s' "$secrets_input") "$@"
