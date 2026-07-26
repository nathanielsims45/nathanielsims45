#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-nathanielsims45/nathanielsims45}"
VAULTX_REPO="${VAULTX_REPO:-nathanielsims45/vaultx}"
CO_AUTHOR_NAME="${CO_AUTHOR_NAME:-}"
CO_AUTHOR_EMAIL="${CO_AUTHOR_EMAIL:-}"

require_gh() {
  if ! command -v gh >/dev/null 2>&1; then
    echo "Install GitHub CLI first: brew install gh"
    exit 1
  fi
  if ! gh auth status >/dev/null 2>&1; then
    echo "Run: gh auth login"
    exit 1
  fi
}

extract_number() {
  sed -E 's#.*/([0-9]+)$#\1#'
}

quickdraw() {
  echo "==> Quickdraw: open and close an issue within 5 minutes"
  local num
  num="$(gh issue create --repo "$REPO" --title "Quickdraw achievement" --body "Temporary issue for GitHub achievement." | extract_number)"
  echo "Created issue #$num — closing now..."
  sleep 2
  gh issue close "$num" --repo "$REPO" --comment "Closed for Quickdraw achievement."
  echo "Quickdraw done (issue #$num)."
}

yolo() {
  echo "==> YOLO: merge a PR without code review"
  local branch="achievement/yolo-$(date +%s)"
  git checkout -B "$branch"
  printf '\n<!-- achievement: yolo -->\n' >> README.md
  git add README.md
  git commit -m "chore: YOLO achievement PR"
  git push -u origin "$branch"
  local pr
  pr="$(gh pr create --repo "$REPO" --head "$branch" --title "YOLO achievement" --body "Merge without review to earn YOLO." | extract_number)"
  gh pr merge "$pr" --repo "$REPO" --merge --delete-branch
  git checkout main && git pull
  echo "YOLO done (PR #$pr)."
}

pull_shark_extra() {
  echo "==> Pull Shark: merge another PR (tier boost if already unlocked)"
  local branch="achievement/pull-shark-$(date +%s)"
  git checkout -B "$branch"
  printf '\n<!-- achievement: pull-shark -->\n' >> README.md
  git add README.md
  git commit -m "chore: Pull Shark achievement PR"
  git push -u origin "$branch"
  local pr
  pr="$(gh pr create --repo "$REPO" --head "$branch" --title "Pull Shark achievement" --body "Merged PR for Pull Shark tier." | extract_number)"
  gh pr merge "$pr" --repo "$REPO" --merge --delete-branch
  git checkout main && git pull
  echo "Pull Shark PR merged (#$pr)."
}

pair_extraordinaire() {
  if [[ -z "$CO_AUTHOR_NAME" || -z "$CO_AUTHOR_EMAIL" ]]; then
    echo "Pair Extraordinaire needs a real collaborator."
    echo "Set: CO_AUTHOR_NAME='Jane Doe' CO_AUTHOR_EMAIL='jane@example.com'"
    echo "That person must be a real GitHub user who agrees to co-author."
    return 1
  fi

  echo "==> Pair Extraordinaire: co-authored merged PR"
  local branch="achievement/pair-$(date +%s)"
  git checkout -B "$branch"
  printf '\n<!-- achievement: pair-extraordinaire -->\n' >> README.md
  git add README.md
  git commit -m "$(cat <<EOF
chore: Pair Extraordinaire achievement

Co-authored-by: ${CO_AUTHOR_NAME} <${CO_AUTHOR_EMAIL}>
EOF
)"
  git push -u origin "$branch"
  local pr
  pr="$(gh pr create --repo "$REPO" --head "$branch" --title "Pair Extraordinaire achievement" --body "Co-authored PR for Pair Extraordinaire." | extract_number)"
  gh pr merge "$pr" --repo "$REPO" --merge --delete-branch
  git checkout main && git pull
  echo "Pair Extraordinaire done (PR #$pr)."
}

enable_discussions() {
  echo "==> Enabling Discussions on $VAULTX_REPO (for Galaxy Brain prep)"
  gh api "repos/${VAULTX_REPO}" -X PATCH -f has_discussions=true >/dev/null
  echo "Discussions enabled on $VAULTX_REPO."
  echo "Galaxy Brain: answer 2 discussions elsewhere and get accepted answers."
  echo "Tip: search 'is:open label:question' on repos you know well."
}

public_sponsor_note() {
  cat <<'EOF'

==> Public Sponsor (manual)
1. Open https://github.com/sponsors
2. Sponsor any open source developer ($1/month is enough)
3. Badge appears after payment processes

EOF
}

starstruck_note() {
  cat <<'EOF'

==> Starstruck (manual, hardest)
Need 16+ stars on a repo you own.
- Polish vaultx or nathanielsims45 into something useful
- Share on X, Reddit r/github, Dev.to, Hacker News
- Ask friends/colleagues to star if they find it useful
No safe shortcut — stars must be real engagement.

EOF
}

main() {
  require_gh
  cd "$(git rev-parse --show-toplevel)"

  echo "Repo: $REPO"
  echo
  echo "Already likely earned from your history:"
  echo "  - Pull Shark (2 merged PRs: #1, #3)"
  echo "  - YOLO (if PR #3 merged without review)"
  echo

  read -r -p "Run Quickdraw? [y/N] " q
  [[ "$q" =~ ^[Yy]$ ]] && quickdraw

  read -r -p "Run YOLO (extra PR, safe if not earned yet)? [y/N] " y
  [[ "$y" =~ ^[Yy]$ ]] && yolo

  read -r -p "Run extra Pull Shark PR? [y/N] " p
  [[ "$p" =~ ^[Yy]$ ]] && pull_shark_extra

  read -r -p "Run Pair Extraordinaire (needs co-author env vars)? [y/N] " pe
  [[ "$pe" =~ ^[Yy]$ ]] && pair_extraordinaire || true

  read -r -p "Enable Discussions on vaultx? [y/N] " d
  [[ "$d" =~ ^[Yy]$ ]] && enable_discussions || true

  public_sponsor_note
  starstruck_note

  echo "Done. Check achievements at: https://github.com/nathanielsims45"
  echo "Badges can take a few minutes to appear."
}

main "$@"
