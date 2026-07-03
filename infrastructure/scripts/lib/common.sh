#!/usr/bin/env bash

set -euo pipefail

if [[ -n "${BANKING_PLATFORM_COMMON_LOADED:-}" ]]; then
  return 0
fi
readonly BANKING_PLATFORM_COMMON_LOADED=1

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
readonly DEFAULT_AWS_REGION="ap-south-1"
readonly DEFAULT_CLUSTER_NAME="capstone-eks"
readonly DEFAULT_RDS_INSTANCE_ID="banking-db"
readonly AWS_REGION="${AWS_REGION:-$DEFAULT_AWS_REGION}"
readonly CLUSTER_NAME="${CLUSTER_NAME:-$DEFAULT_CLUSTER_NAME}"
readonly RDS_INSTANCE_ID="${RDS_INSTANCE_ID:-$DEFAULT_RDS_INSTANCE_ID}"

if [[ -t 1 ]]; then
  readonly RED=$'\033[0;31m'
  readonly GREEN=$'\033[0;32m'
  readonly YELLOW=$'\033[1;33m'
  readonly BLUE=$'\033[0;34m'
  readonly NC=$'\033[0m'
else
  readonly RED=''
  readonly GREEN=''
  readonly YELLOW=''
  readonly BLUE=''
  readonly NC=''
fi

log() {
  printf '%s[INFO]%s %s\n' "$BLUE" "$NC" "$*"
}

success() {
  printf '%s[SUCCESS]%s %s\n' "$GREEN" "$NC" "$*"
}

step_success() {
  printf '%s✓ Success%s %s\n' "$GREEN" "$NC" "$*"
}

step_failure() {
  printf '%s✗ Failure%s %s\n' "$RED" "$NC" "$*" >&2
}

step_warning() {
  printf '%sWarnings:%s %s\n' "$YELLOW" "$NC" "$*" >&2
}

warn() {
  printf '%s[WARN]%s %s\n' "$YELLOW" "$NC" "$*" >&2
}

fail() {
  printf '%s[ERROR]%s %s\n' "$RED" "$NC" "$*" >&2
  exit 1
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || fail "Required command not found: $cmd"
}

optional_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1
}

aws_cli() {
  aws --region "$AWS_REGION" "$@"
}

check_aws_login() {
  require_cmd aws
  aws sts get-caller-identity >/dev/null || fail "AWS credentials are not valid or not configured."
}

update_kubeconfig() {
  require_cmd aws
  log "Updating kubeconfig for cluster ${CLUSTER_NAME} in ${AWS_REGION}"
  aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"
}

kubectl_available() {
  require_cmd kubectl
  kubectl version --client >/dev/null
}

section() {
  printf '\n%s== %s ==%s\n' "$BLUE" "$*" "$NC"
}

now_seconds() {
  date +%s
}

elapsed_time() {
  local start="$1"
  local end
  end="$(now_seconds)"
  printf '%ss' "$((end - start))"
}

run_step() {
  local title="$1"
  shift

  section "$title"
  local started
  started="$(now_seconds)"

  if "$@"; then
    step_success "$title completed. Elapsed Time: $(elapsed_time "$started")"
  else
    local rc=$?
    step_failure "$title failed with exit code ${rc}. Elapsed Time: $(elapsed_time "$started")"
    return "$rc"
  fi
}

print_kv() {
  printf '%-32s %s\n' "$1:" "$2"
}

confirm_or_exit() {
  local expected="$1"
  local prompt="$2"
  local value="${3:-}"

  if [[ "$value" == "$expected" ]]; then
    return 0
  fi

  warn "$prompt"
  warn "Set CONFIRM=${expected} or pass --yes when supported."
  exit 2
}

repo_path() {
  printf '%s/%s\n' "$REPO_ROOT" "$1"
}
