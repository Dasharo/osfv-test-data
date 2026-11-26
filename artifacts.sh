#!/usr/bin/env bash

# Operations on the ARTIFACTS of */Makefile, called by the Taskfile:
# artifacts.sh list|build DIR...|check|forget|clean|changed|mirror

set -euo pipefail
shopt -s inherit_errexit

FTP_SUBDIR="osfv-test-data"
PUBLIC_URL="${PUBLIC_URL:-https://dl.3mdeb.com/open-source-firmware/Dasharo/osfv-test-data}"

# Never record this clone in the git-annex branch, even if annex auto-initializes
git config annex.private true

makevar() {
  make -s --no-print-directory -C "$1" --eval "print-var: ; @echo \$($2)" print-var
}

# A failing $(...) in a for list goes unnoticed, so it is assigned first
list() {
  local dir artifacts artifact
  for dir in $(dirname */Makefile); do
    artifacts=$(makevar "$dir" ARTIFACTS)
    for artifact in $artifacts; do
      echo "$dir/$artifact"
    done
  done
}

on_ftp() {
  local key
  key=$(git annex lookupkey "$1")
  git annex whereis --key="$key" 2>/dev/null | grep -F "${PUBLIC_URL}/${key}" >/dev/null
}

build() {
  local dir artifacts artifact
  for dir in "$@"; do
    artifacts=$(makevar "$dir" ARTIFACTS)
    for artifact in $artifacts; do
      make -B -C "$dir" "$artifact"
      git annex add "$dir/$artifact"
    done
  done
}

# Content lives only on the FTP, so the git-annex branch must record no repository
check() {
  local listed annexed repos
  listed=$(list)
  annexed=$(git annex find --include='*')
  diff -u --label ARTIFACTS --label annexed <(printf '%s\n' "$listed" | sort) <(printf '%s\n' "$annexed" | sort)
  if git cat-file -e git-annex:uuid.log 2>/dev/null; then
    repos=$(git show git-annex:uuid.log)
    if [ -n "$repos" ]; then
      echo "The git-annex branch records these repositories, run task forget:" >&2
      echo "$repos" >&2
      exit 1
    fi
  fi
}

forget() {
  local uuids uuid
  git cat-file -e git-annex:uuid.log 2>/dev/null || return 0
  uuids=$(git show git-annex:uuid.log | cut -d' ' -f1)
  for uuid in $uuids; do
    git annex dead "$uuid"
  done
  git annex forget --drop-dead --force
}

# Publish commits only artifacts, built from committed sources
clean() {
  local artifacts status path dirty=0
  artifacts=" $(list | tr '\n' ' ') "
  status=$(git status --porcelain --untracked-files=all)
  while read -r _ path; do
    if [ -n "$path" ] && [[ "$artifacts" != *" $path "* ]]; then
      echo "Not committed: $path" >&2
      dirty=1
    fi
  done <<<"$status"
  return "$dirty"
}

# Directories missing an artifact on the FTP, or whose Makefile or INPUTS changed
changed() {
  local files artifacts file dir dirartifacts artifact inputs input
  local rebuilt=" " sources=() selected=()
  files=$(printf '%s' "${CI_PIPELINE_FILES:-[]}" | jq -r '.[]')
  artifacts=" $(list | tr '\n' ' ') "
  for file in $files; do
    if [[ "$artifacts" == *" $file "* ]]; then
      rebuilt+="${file%%/*} "
    else
      sources+=("$file")
    fi
  done
  for dir in $(dirname */Makefile); do
    dirartifacts=$(makevar "$dir" ARTIFACTS)
    for artifact in $dirartifacts; do
      if ! on_ftp "$dir/$artifact"; then
        selected+=("$dir")
        continue 2
      fi
    done
    if [[ "$rebuilt" == *" $dir "* ]]; then
      continue
    fi
    inputs=$(makevar "$dir" INPUTS)
    for input in Makefile $inputs; do
      input=$(realpath -m --relative-to=. "$dir/$input")
      for file in "${sources[@]}"; do
        if [[ "$file" == "$input" || "$file" == "$input"/* ]]; then
          selected+=("$dir")
          continue 3
        fi
      done
    done
  done
  echo "${selected[*]}"
}

# Quote an lftp command argument, escaping \ and "
lftp_quote() {
  local s=${1//\\/\\\\}
  printf '"%s"' "${s//\"/\\\"}"
}

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
      # Password via the environment, so it reaches neither ps nor the log
      if ! LFTP_PASSWORD="$FTP_PASSWORD" lftp 2>&1 >/dev/null <<EOF
set net:max-retries 2
set net:timeout 30
open --env-password -u $(lftp_quote "$FTP_LOGIN") $(lftp_quote "$FTP_DOMAIN")
mkdir -p $(lftp_quote "$dir")
cd $(lftp_quote "$dir")
put $(lftp_quote "$object")
bye
EOF
      then
        echo "Uploading $file failed, check FTP_DOMAIN, FTP_LOGIN, FTP_PASSWORD and FTP_REMOTE_DIR_PREFIX" >&2
        exit 1
      fi

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
