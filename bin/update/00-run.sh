#!/usr/bin/env bash
set -euo pipefail

RELEASE=$1
UMBREL_ROOT=$2
UMBREL_USER=$3

echo
echo "======================================="
echo "============= OTA UPDATE =============="
echo "======================================="
echo "========= Stage: Pre-update ==========="
echo "======================================="
echo

# Make sure any previous backup doesn't exist 
if [[ -d $UMBREL_ROOT/.umbrel-backup ]]; then
    echo "Cannot install update. A previous backup already exists at $UMBREL_ROOT/.umbrel-backup"
    echo "This can only happen if the previous update installation wasn't successful"
    exit 1
fi

echo "Installing Umbrel $RELEASE at $UMBREL_ROOT"

# Update status file
cat <<EOF > $UMBREL_ROOT/statuses/update-status.json
{"state": "installing", "progress": 20, "description": "Backing up"}
EOF

# Fix permissions
echo "Fixing permissions"
chown -R $UMBREL_USER:$UMBREL_USER $UMBREL_ROOT/

# Backup
echo "Backing up existing directory tree"

IGNORE_LIST=$(cat $UMBREL_ROOT/.umbrel-$RELEASE/bin/update/.updateignore)
excludes=()
for toignore in $IGNORE_LIST; do
    excludes+=(--exclude "'$toignore'")
done
echo "Excluding from backup: ${excludes[@]}"

rsync -av $UMBREL_ROOT/ \
    "${excludes[@]}"\
    $UMBREL_ROOT/.umbrel-backup/

echo "Successfully backed up to $UMBREL_ROOT/.umbrel-backup"
