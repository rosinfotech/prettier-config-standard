#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/get_home_secret.sh"

NPM_LOGIN=$(getHomeSecret '.npm.tech.rosinfo.login')
NPM_TOKEN=$(getHomeSecret '.npm.tech.rosinfo.token')

if [ -z "$NPM_LOGIN" ] || [ "$NPM_LOGIN" = "null" ]; then
    echo "Error: NPM login not found in secrets (.npm.tech.rosinfo.login)"
    exit 1
fi

if [ -z "$NPM_TOKEN" ] || [ "$NPM_TOKEN" = "null" ]; then
    echo "Error: NPM token not found in secrets (.npm.tech.rosinfo.token)"
    exit 1
fi

echo "NPM login: $NPM_LOGIN"

PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

NPM_DIR="$PROJECT_ROOT/npm"
rm -rf "$NPM_DIR"
mkdir -p "$NPM_DIR"

echo "Copying files to npm directory..."

cp "$PROJECT_ROOT/index.js" "$NPM_DIR/"
cp "$PROJECT_ROOT/package.json" "$NPM_DIR/"

cat > "$NPM_DIR/.npmrc" << EOF
//registry.npmjs.org/:_authToken=$NPM_TOKEN
$NPM_LOGIN:registry=https://registry.npmjs.org/
EOF

echo ".npmrc file created"

cd "$NPM_DIR"

echo "Publishing to npm..."
npm publish --access public

echo "Successfully published to npm!"

cd "$PROJECT_ROOT"
rm -rf "$NPM_DIR"

echo "Cleanup completed"
