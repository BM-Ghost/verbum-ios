#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

violations=0

print_header() {
  echo ""
  echo "== $1 =="
}

collect_files() {
  local root="$1"
  shift
  local patterns=("$@")

  for pattern in "${patterns[@]}"; do
    find "$root" -type f -name "$pattern"
  done | sort -u
}

check_pattern() {
  local title="$1"
  local regex="$2"
  local root="$3"
  shift 3
  local patterns=("$@")

  print_header "$title"

  local found=0
  while IFS= read -r file; do
    if grep -nE "$regex" "$file" >/tmp/verbum_guidelines_match.txt 2>/dev/null; then
      found=1
      while IFS= read -r match; do
        echo "$file:$match"
      done </tmp/verbum_guidelines_match.txt
    fi
  done < <(collect_files "$root" "${patterns[@]}")

  rm -f /tmp/verbum_guidelines_match.txt

  if [[ $found -eq 1 ]]; then
    violations=$((violations + 1))
  else
    echo "No violations."
  fi
}

# 1) Disallow force unwraps in source files.
#    Ignore optional type declarations and dictionary bang operators in comments/strings by using a conservative regex.
check_pattern \
  "No force unwraps (!)" \
  '[A-Za-z0-9_\)\]\}>]![\s\)\]\}>.,?:;]' \
  "Verbum" \
  "*.swift"

# 2) Disallow direct persistence imports in UI and ViewModel files.
check_pattern \
  "No direct SwiftData/CoreData imports in UI or ViewModel files" \
  '^import[[:space:]]+(SwiftData|CoreData)$' \
  "Verbum" \
  "*Screen.swift" "*View.swift" "*Content.swift" "*ViewModel.swift"

# 3) Disallow direct URLSession usage in UI and ViewModel layers.
check_pattern \
  "No direct URLSession usage in UI or ViewModel files" \
  'URLSession\\.' \
  "Verbum" \
  "*Screen.swift" "*View.swift" "*Content.swift" "*ViewModel.swift"

# 4) Disallow hardcoded colors in feature-level UI.
check_pattern \
  "No hardcoded Color(...) values in feature UI" \
  'Color\\((0x|red:|white:|hue:|\.sRGB|\.displayP3)' \
  "Verbum/Features" \
  "*.swift"

# 5) Avoid feature-to-feature imports.
check_pattern \
  "No feature-to-feature imports" \
  '^import[[:space:]]+VerbumFeatures[A-Za-z]+' \
  "Verbum/Features" \
  "*.swift"

# 6) Every screen should expose a preview block in the same file.
print_header "Every *Screen.swift file includes a preview"
missing_previews=0
central_preview_file="Verbum/Previews/KeyScreenPreviews.swift"
while IFS= read -r file; do
  if grep -Eq '#Preview|PreviewProvider|@Preview' "$file"; then
    continue
  fi

  screen_name="$(basename "$file" .swift)"
  if [[ -f "$central_preview_file" ]] && grep -Eq "${screen_name}[[:space:]]*\\(" "$central_preview_file"; then
    continue
  fi

  missing_previews=1
  echo "$file"
done < <(find Verbum/Features -name '*Screen.swift' -type f | sort)

if [[ $missing_previews -eq 1 ]]; then
  violations=$((violations + 1))
else
  echo "No violations."
fi

print_header "Summary"
if [[ $violations -gt 0 ]]; then
  echo "Guideline verification failed with $violations violation group(s)."
  exit 1
fi

echo "All verbum guidelines checks passed."
