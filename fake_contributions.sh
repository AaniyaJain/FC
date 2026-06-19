#!/bin/bash
# fake_contributions.sh
# Generates backdated commits for the past 2 years (10–15 commits/month)
# Usage: bash fake_contributions.sh

REPO_DIR="contrib-history"
AUTHOR_NAME="$(git config user.name)"
AUTHOR_EMAIL="$(git config user.email)"

mkdir -p "$REPO_DIR" && cd "$REPO_DIR"
git init

# Generate commits from 2 years ago to today
START_DATE=$(date -d "2 years ago" +%Y-%m-%d 2>/dev/null || date -v-2y +%Y-%m-%d)

current="$START_DATE"
today=$(date +%Y-%m-%d)

while [[ "$current" < "$today" ]]; do
  # Random number of commits this month: 10–15
  count=$((RANDOM % 6 + 10))

  year=$(echo "$current" | cut -d'-' -f1)
  month=$(echo "$current" | cut -d'-' -f2)

  # Get days in month
  days_in_month=$(cal "$month" "$year" | awk 'NF{last=$NF} END{print last}')

  for ((i=1; i<=count; i++)); do
    day=$((RANDOM % days_in_month + 1))
    day=$(printf "%02d" $day)
    commit_date="${year}-${month}-${day}T$(printf "%02d" $((RANDOM % 23))):$(printf "%02d" $((RANDOM % 59))):00"

    echo "update $i - $commit_date" >> activity.log

    GIT_AUTHOR_DATE="$commit_date" \
    GIT_COMMITTER_DATE="$commit_date" \
    GIT_AUTHOR_NAME="$AUTHOR_NAME" \
    GIT_AUTHOR_EMAIL="$AUTHOR_EMAIL" \
    GIT_COMMITTER_NAME="$AUTHOR_NAME" \
    GIT_COMMITTER_EMAIL="$AUTHOR_EMAIL" \
    git commit --allow-empty -m "chore: activity log update [$i]" --date="$commit_date"
  done

  # Advance by 1 month
  current=$(date -d "$current +1 month" +%Y-%m-%d 2>/dev/null || date -j -v+1m -f "%Y-%m-%d" "$current" +%Y-%m-%d)
done

echo ""
echo "Done! $REPO_DIR is ready."
echo "Push with:"
echo "  cd $REPO_DIR"
echo "  git remote add origin <your-github-repo-url>"
echo "  git push -u origin main"
