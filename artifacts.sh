#!/usr/bin/env bash

# Operations on the annexed files, called by the Taskfile: artifacts.sh mirror

set -euo pipefail

FTP_SUBDIR="osfv-test-data"
PUBLIC_URL="${PUBLIC_URL:-https://dl.3mdeb.com/open-source-firmware/Dasharo/osfv-test-data}"

# Upload each annexed file as its key, then keep the FTP URL as its only URL
mirror() {
  local dir files file key url hash object served others other
  : "${FTP_DOMAIN:?}" "${FTP_LOGIN:?}" "${FTP_PASSWORD:?}"
  dir="${FTP_REMOTE_DIR_PREFIX:+$FTP_REMOTE_DIR_PREFIX/}${FTP_SUBDIR}"
  files=$(git annex find --include='*')
  for file in $files; do
    key=$(git annex lookupkey "$file")
    url="${PUBLIC_URL}/${key}"

    if git annex whereis --key="$key" | grep -F "$url" >/dev/null; then
      echo "$file is already on the FTP"
    else
      if [[ "$key" != SHA256E-* ]]; then
        echo "$file has no checksum, run: git annex migrate --backend=SHA256E $file" >&2
        exit 1
      fi
      hash="${key#*--}"
      hash="${hash%%.*}"
      git annex get --key="$key"
      object=$(git annex contentlocation "$key")
      echo "Uploading $file"
      # Credentials via stdin and no output, so they reach neither ps nor the log
      lftp &>/dev/null <<EOF
set net:max-retries 2
set net:timeout 30
open -u ${FTP_LOGIN},${FTP_PASSWORD} ${FTP_DOMAIN}
mkdir -p ${dir}
cd ${dir}
put ${object}
bye
EOF
      echo "Verifying $url"
      if ! served=$(curl -fL --progress-bar "$url" | sha256sum) || [ "${served%% *}" != "$hash" ]; then
        echo "Uploading $file failed or $url does not serve it, check FTP_DOMAIN, FTP_LOGIN, FTP_PASSWORD and FTP_REMOTE_DIR_PREFIX" >&2
        exit 1
      fi
      git annex registerurl "$key" "$url"
    fi

    others=$(git annex whereis --key="$key" | sed -n 's/^[[:space:]]*web: //p' | awk -v keep="$url" '$0 != keep')
    for other in $others; do
      git annex rmurl "$file" "$other"
    done
  done
}

"$@"
