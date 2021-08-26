#! /usr/bin/env nix-shell
#! nix-shell -i bash -p git gnupg
set -euo pipefail

TMPDIR="$(mktemp -d -p /tmp)"
trap "rm -rf $TMPDIR" EXIT
cd $TMPDIR

echo "Fetching latest release"
git clone https://github.com/lightninglabs/loop 2> /dev/null
cd loop
latest=$(git describe --tags `git rev-list --tags --max-count=1`)
echo "Latest release is ${latest}"

# GPG verification
export GNUPGHOME=$TMPDIR
echo "Fetching Joost Jager's Key"
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys D146D0F68939436268FA9A130E26BB61B76C4D3A #2> /dev/null

wget https://github.com/lightninglabs/loop/releases/download/${latest}/manifest-${latest}.txt.sig 2> /dev/null
wget https://github.com/lightninglabs/loop/releases/download/${latest}/manifest-${latest}.txt 2> /dev/null
gpg2 --verify manifest-${latest}.txt.sig manifest-${latest}.txt

echo "sha256: $(cat manifest-${latest}.txt | grep loop-source-${latest}.tar.gz | cut -d\  -f1)"
