#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---staged}"

if [[ "${MODE}" != "--staged" && "${MODE}" != "--all" ]]; then
  echo "Usage: $0 [--staged|--all]" >&2
  exit 2
fi

SECRET_REGEX='(AIza[0-9A-Za-z_-]{35}|AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN (RSA|EC|OPENSSH|DSA|PRIVATE) PRIVATE KEY-----|[0-9]{10,}-[a-z0-9-]{16,}\.apps\.googleusercontent\.com)'

has_issues=0

is_forbidden_file() {
  local path="$1"
  local base="${path##*/}"

  case "${base}" in
    GoogleService-Info*.plist|GoogleService-Info*.plist.*)
      case "${base}" in
        GoogleService-Info.example.plist|GoogleService-Info.example.plist.plist)
          return 1
          ;;
        *)
          return 0
          ;;
      esac
      ;;
    Secrets*.plist)
      case "${base}" in
        Secrets.example.plist)
          return 1
          ;;
        *)
          return 0
          ;;
      esac
      ;;
    .env|.env.*)
      case "${base}" in
        .env.example|.env.sample|.env.template)
          return 1
          ;;
        *)
          return 0
          ;;
      esac
      ;;
    *.pem|*.p8|*.p12|*.mobileprovision|*.jks|*.keystore)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

collect_files() {
  if [[ "${MODE}" == "--all" ]]; then
    git ls-files
  else
    git diff --cached --name-only --diff-filter=ACMR
  fi
}

check_forbidden_files() {
  local file
  local blocked=()

  while IFS= read -r file; do
    [[ -z "${file}" ]] && continue
    if is_forbidden_file "${file}"; then
      blocked+=("${file}")
    fi
  done < <(collect_files)

  if (( ${#blocked[@]} > 0 )); then
    echo "ERROR: Sensitive file names detected:" >&2
    printf '  - %s\n' "${blocked[@]}" >&2
    has_issues=1
  fi
}

check_staged_content() {
  local staged_lines
  local matches

  staged_lines="$(
    git diff --cached --no-color -U0 | awk '
      /^diff --git / {
        file=$4
        sub("^b/", "", file)
        next
      }
      /^\+\+\+ / { next }
      /^\+/ {
        print file ":" substr($0, 2)
      }
    '
  )"

  [[ -z "${staged_lines}" ]] && return 0

  matches="$(printf '%s\n' "${staged_lines}" | grep -nE "${SECRET_REGEX}" || true)"
  if [[ -n "${matches}" ]]; then
    echo "ERROR: Secret-like values found in staged added lines:" >&2
    echo "${matches}" >&2
    has_issues=1
  fi
}

check_repo_content() {
  local matches
  matches="$(git grep -nI -E "${SECRET_REGEX}" -- . || true)"
  if [[ -n "${matches}" ]]; then
    echo "ERROR: Secret-like values found in tracked files:" >&2
    echo "${matches}" >&2
    has_issues=1
  fi
}

check_forbidden_files

if [[ "${MODE}" == "--all" ]]; then
  check_repo_content
else
  check_staged_content
fi

if (( has_issues > 0 )); then
  echo "Secret check failed." >&2
  exit 1
fi

echo "Secret check passed (${MODE})."

