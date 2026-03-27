#!/bin/zsh
set -euo pipefail

# Formats changed Swift files (tracked + untracked) with swift-format.
# Optional flag:
#   --build   Runs an Xcode build check after formatting.

run_build=false
if [[ "${1:-}" == "--build" ]]; then
  run_build=true
fi

repo_root="$(cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$repo_root"

if ! xcrun --find swift-format >/dev/null 2>&1; then
  echo "swift-format not found via xcrun."
  exit 1
fi

typeset -a files
while IFS= read -r file; do
  [[ -n "$file" ]] && files+=("$file")
done < <(git diff --name-only --diff-filter=ACM HEAD -- '*.swift')

while IFS= read -r file; do
  [[ -n "$file" ]] && files+=("$file")
done < <(git ls-files --others --exclude-standard -- '*.swift')

typeset -A seen
typeset -a unique_files
for file in "${files[@]}"; do
  [[ -n "${seen[$file]:-}" ]] && continue
  seen[$file]=1
  unique_files+=("$file")
done

if (( ${#unique_files[@]} == 0 )); then
  echo "No changed Swift files to format."
  exit 0
fi

echo "Formatting ${#unique_files[@]} changed Swift file(s)..."
xcrun swift-format format --in-place "${unique_files[@]}"
echo "Formatting complete."

if [[ "$run_build" == true ]]; then
  echo "Running build check..."
  xcodebuild -project CineMate.xcodeproj \
    -scheme CineMate \
    -destination 'generic/platform=iOS Simulator' \
    build 2>&1 | rg -n "warning:|BUILD SUCCEEDED|BUILD FAILED|error:"
fi
