#!/usr/bin/env bash
# claude-wyvrn — installer and CLI for the Wyvrn Claude harness.
# Bootstrap:  curl -fsSL https://raw.githubusercontent.com/andrewputrajaya/claude-wyvrn/main/install.sh | bash
# Installed:  invoked as `claude-wyvrn <verb>` after first install.

set -euo pipefail

REPO="andrewputrajaya/claude-wyvrn"
INSTALL_DIR="$HOME/.claude-wyvrn"
BIN_DIR="$HOME/.local/bin"
SHIM="$BIN_DIR/claude-wyvrn"
INTERNAL_SCRIPT="$INSTALL_DIR/.bin/install.sh"
MANIFEST="$INSTALL_DIR/.installed-manifest.txt"
SKELETON_DIR="$INSTALL_DIR/.skeleton"
TARBALL_NAME="claude-wyvrn.tar.gz"
SUMS_NAME="SHA256SUMS"

die() { echo "claude-wyvrn: $*" >&2; exit 1; }
log() { echo "claude-wyvrn: $*"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

resolve_version() {
  local v="${CLAUDE_WYVRN_VERSION:-latest}"
  if [ "$v" = "latest" ]; then
    echo "latest"
  elif [ "$v" = "local" ]; then
    echo "local"
  else
    echo "${v#v}"
  fi
}

download() {
  local url="$1" out="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$out"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$url" -O "$out"
  else
    die "need curl or wget to download $url"
  fi
}

verify_sha256() {
  local file="$1" expected="$2" actual
  if command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "$file" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    actual="$(shasum -a 256 "$file" | awk '{print $1}')"
  else
    die "need sha256sum or shasum to verify checksums"
  fi
  [ "$actual" = "$expected" ] || die "checksum mismatch for $file (expected $expected, got $actual)"
  log "verified sha256: $actual"
}

write_manifest() {
  local version="$1" root="$2"
  {
    echo "# claude-wyvrn manifest"
    echo "# version: $version"
    echo "# installed_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    if command -v sha256sum >/dev/null 2>&1; then
      ( cd "$root" && find . -type f ! -path './.installed-manifest.txt' ! -path './.bin/*' ! -path './.skeleton/*' -print0 | sort -z | xargs -0 sha256sum )
    else
      ( cd "$root" && find . -type f ! -path './.installed-manifest.txt' ! -path './.bin/*' ! -path './.skeleton/*' -print0 | sort -z | xargs -0 shasum -a 256 )
    fi
  } > "$MANIFEST"
}

install_shim() {
  mkdir -p "$BIN_DIR" "$INSTALL_DIR/.bin"
  local src="$1" tmp="$2"
  if [ -n "$tmp" ] && [ -f "$tmp/install.sh" ]; then
    cp "$tmp/install.sh" "$INTERNAL_SCRIPT"
  elif [ -n "$src" ] && [ -f "$src" ]; then
    local abs_src abs_dest
    abs_src="$(cd "$(dirname "$src")" 2>/dev/null && pwd)/$(basename "$src")"
    abs_dest="$(cd "$(dirname "$INTERNAL_SCRIPT")" 2>/dev/null && pwd)/$(basename "$INTERNAL_SCRIPT")"
    if [ "$abs_src" != "$abs_dest" ]; then
      cp "$src" "$INTERNAL_SCRIPT"
    fi
  else
    die "cannot install CLI shim: install.sh not available from release or local path (this should not happen — please report)"
  fi
  chmod +x "$INTERNAL_SCRIPT" 2>/dev/null || true
  cat > "$SHIM" <<'EOF'
#!/usr/bin/env bash
exec "$HOME/.claude-wyvrn/.bin/install.sh" "$@"
EOF
  chmod +x "$SHIM"
}

ensure_path_hint() {
  case ":${PATH:-}:" in
    *":$BIN_DIR:"*) ;;
    *) log "note: $BIN_DIR is not in PATH. Add this to your shell profile:"
       log "  export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
  esac
}

fetch_release() {
  local version="$1" tmp="$2"
  local base
  if [ "$version" = "latest" ]; then
    base="https://github.com/$REPO/releases/latest/download"
  else
    base="https://github.com/$REPO/releases/download/v$version"
  fi
  log "downloading $base/$TARBALL_NAME"
  download "$base/$TARBALL_NAME" "$tmp/$TARBALL_NAME"
  download "$base/$SUMS_NAME"    "$tmp/$SUMS_NAME"
  download "$base/install.sh"    "$tmp/install.sh"
  local name expected
  for name in "$TARBALL_NAME" "install.sh"; do
    expected="$(awk -v f="$name" '$2==f{print $1}' "$tmp/$SUMS_NAME")"
    [ -n "$expected" ] || die "$name not listed in $SUMS_NAME"
    verify_sha256 "$tmp/$name" "$expected"
  done
}

extract_release() {
  local tmp="$1"
  ( cd "$tmp" && tar -xzf "$TARBALL_NAME" )
  [ -d "$tmp/.claude-wyvrn" ] || die "release archive missing .claude-wyvrn/"
  [ -d "$tmp/.skeleton" ]     || die "release archive missing .skeleton/"
}

prepare_local_source() {
  local self_dir="$1" tmp="$2"
  [ -d "$self_dir/.claude-wyvrn" ] || die "local mode: $self_dir/.claude-wyvrn not found (run from repo root)"
  [ -d "$self_dir/.claude-wyvrn-local" ] || die "local mode: $self_dir/.claude-wyvrn-local not found"
  [ -f "$self_dir/CLAUDE.md" ] || die "local mode: $self_dir/CLAUDE.md not found"
  cp -R "$self_dir/.claude-wyvrn" "$tmp/.claude-wyvrn"
  mkdir -p "$tmp/.skeleton"
  cp -R "$self_dir/.claude-wyvrn-local" "$tmp/.skeleton/.claude-wyvrn-local"
  cp    "$self_dir/CLAUDE.md"           "$tmp/.skeleton/CLAUDE.md"
}

apply_payload() {
  local tmp="$1" version="$2"
  mkdir -p "$INSTALL_DIR"
  for entry in "$INSTALL_DIR"/* "$INSTALL_DIR"/.[!.]*; do
    [ -e "$entry" ] || continue
    case "$(basename "$entry")" in
      .bin|bin|.installed-manifest.txt) ;;
      *) rm -rf "$entry" ;;
    esac
  done
  cp -R "$tmp/.claude-wyvrn/." "$INSTALL_DIR/"
  rm -rf "$INSTALL_DIR/.skeleton"
  mkdir -p "$INSTALL_DIR/.skeleton"
  cp -R "$tmp/.skeleton/." "$INSTALL_DIR/.skeleton/"
  install_shim "${BASH_SOURCE[0]:-}" "$tmp"
  write_manifest "$version" "$INSTALL_DIR"
}

cmd_install() {
  local version
  version="$(resolve_version)"
  if [ -f "$INSTALL_DIR/VERSION" ] && [ "$version" != "local" ]; then
    local current
    current="$(tr -d ' \n\r' < "$INSTALL_DIR/VERSION")"
    if [ "$version" != "latest" ] && [ "$version" = "$current" ]; then
      log "already at version $current"
      return 0
    fi
  fi
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  if [ "$version" = "local" ]; then
    local self_dir
    self_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    log "installing from local source at $self_dir"
    prepare_local_source "$self_dir" "$tmp"
    version="$(tr -d ' \n\r' < "$tmp/.claude-wyvrn/VERSION")-local"
  else
    require_cmd tar
    fetch_release "$version" "$tmp"
    extract_release "$tmp"
    if [ "$version" = "latest" ]; then
      version="$(tr -d ' \n\r' < "$tmp/.claude-wyvrn/VERSION")"
    fi
  fi
  apply_payload "$tmp" "$version"
  log "installed claude-wyvrn $version to $INSTALL_DIR"
  ensure_path_hint
}

cmd_update() {
  [ -d "$INSTALL_DIR" ] || die "not installed. Run: claude-wyvrn install"
  cmd_install
}

cmd_init() {
  [ -d "$SKELETON_DIR" ] || die "skeleton missing at $SKELETON_DIR. Run: claude-wyvrn install"
  if [ -d "./.claude-wyvrn-local" ]; then
    die "project already initialized (.claude-wyvrn-local/ exists). To update skeleton structure and CLAUDE.md, run: claude-wyvrn refresh"
  fi
  local preserved=""
  if [ -f "./CLAUDE.md" ]; then
    if ! cmp -s "./CLAUDE.md" "$SKELETON_DIR/CLAUDE.md"; then
      preserved="$(cat ./CLAUDE.md)"
    fi
  fi
  cp -R "$SKELETON_DIR/.claude-wyvrn-local" "./.claude-wyvrn-local"
  cp    "$SKELETON_DIR/CLAUDE.md"           "./CLAUDE.md"
  if [ -n "$preserved" ]; then
    printf '%s' "$preserved" > "./.claude-wyvrn-local/PROJECT.md"
    log "preserved previous CLAUDE.md content to .claude-wyvrn-local/PROJECT.md"
  fi
  log "initialized project skeleton in $(pwd)"
}

cmd_uninit() {
  [ -d "./.claude-wyvrn-local" ] || die ".claude-wyvrn-local/ not found in cwd; nothing to uninit"
  local force=0
  for arg in "$@"; do
    case "$arg" in --force|-f) force=1 ;; esac
  done
  local dirty=()
  for d in features fixes refactors decisions clarifications reviews verifier-gaps .archive conventions; do
    local path="./.claude-wyvrn-local/$d"
    if [ -d "$path" ]; then
      local count
      count=$(find "$path" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ')
      if [ "$count" -gt 0 ]; then dirty+=("$d/ ($count file(s))"); fi
    fi
  done
  if [ -f "./.claude-wyvrn-local/ARCHITECTURE.md" ] && [ -f "$SKELETON_DIR/.claude-wyvrn-local/ARCHITECTURE.md" ]; then
    if ! cmp -s "./.claude-wyvrn-local/ARCHITECTURE.md" "$SKELETON_DIR/.claude-wyvrn-local/ARCHITECTURE.md"; then
      dirty+=("ARCHITECTURE.md (modified from template)")
    fi
  fi
  if [ ${#dirty[@]} -gt 0 ] && [ "$force" = "0" ]; then
    echo "claude-wyvrn: uninit would discard the following user content:" >&2
    for d in "${dirty[@]}"; do echo "  - $d" >&2; done
    die "refusing to uninit. Back up the listed items, then re-run with --force."
  fi
  if [ -f "./.claude-wyvrn-local/PROJECT.md" ]; then
    mv -f "./.claude-wyvrn-local/PROJECT.md" "./CLAUDE.md"
    log "restored CLAUDE.md from PROJECT.md"
  elif [ -f "./CLAUDE.md" ]; then
    rm -f "./CLAUDE.md"
    log "removed CLAUDE.md"
  fi
  rm -rf "./.claude-wyvrn-local"
  log "removed .claude-wyvrn-local/"
  log "uninit complete; project no longer depends on claude-wyvrn"
}

cmd_refresh() {
  [ -d "$SKELETON_DIR" ] || die "skeleton missing at $SKELETON_DIR. Run: claude-wyvrn install"
  [ -d "./.claude-wyvrn-local" ] || die ".claude-wyvrn-local/ not found in cwd. Run: claude-wyvrn init"
  if [ ! -f "./CLAUDE.md" ] || ! cmp -s "./CLAUDE.md" "$SKELETON_DIR/CLAUDE.md"; then
    cp "$SKELETON_DIR/CLAUDE.md" "./CLAUDE.md"
    log "updated CLAUDE.md"
  else
    log "CLAUDE.md already up-to-date"
  fi
  local skel_local="$SKELETON_DIR/.claude-wyvrn-local"
  local added=0
  while IFS= read -r -d '' entry; do
    local rel="${entry#$skel_local/}"
    local src="$skel_local/$rel"
    local dest="./.claude-wyvrn-local/$rel"
    if [ -d "$src" ]; then
      if [ ! -d "$dest" ]; then
        mkdir -p "$dest"
        log "added dir: .claude-wyvrn-local/$rel"
        added=$((added + 1))
      fi
    elif [ -f "$src" ]; then
      if [ ! -f "$dest" ]; then
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        log "added file: .claude-wyvrn-local/$rel"
        added=$((added + 1))
      fi
    fi
  done < <(find "$skel_local" -mindepth 1 -print0)
  if [ "$added" -eq 0 ]; then
    log "skeleton already complete; PROJECT.md, ARCHITECTURE.md, and artifacts left untouched"
  else
    log "refresh complete ($added items added; PROJECT.md, ARCHITECTURE.md, and artifacts left untouched)"
  fi
}

cmd_doctor() {
  [ -d "$INSTALL_DIR" ] || die "not installed at $INSTALL_DIR"
  for f in VERSION HARNESS.md INDEX.md; do
    [ -f "$INSTALL_DIR/$f" ] || die "required file missing: $INSTALL_DIR/$f"
  done
  local current
  current="$(tr -d ' \n\r' < "$INSTALL_DIR/VERSION")"
  log "installed: $current"
  if [ -f "$MANIFEST" ]; then
    if ( cd "$INSTALL_DIR" && (command -v sha256sum >/dev/null 2>&1 && sha256sum -c "$MANIFEST" --quiet --ignore-missing) ) >/dev/null 2>&1; then
      log "manifest: ok"
    else
      log "manifest: MISMATCH (run: claude-wyvrn update)"
    fi
  else
    log "manifest: missing"
  fi
  case ":${PATH:-}:" in
    *":$BIN_DIR:"*) log "PATH: $BIN_DIR present" ;;
    *) log "PATH: $BIN_DIR NOT in PATH" ;;
  esac
  if command -v curl >/dev/null 2>&1; then
    local latest
    latest="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null | awk -F'"' '/"tag_name"/{print $4; exit}' | sed 's/^v//')"
    if [ -n "$latest" ] && [ "$latest" != "$current" ]; then
      log "update available: $latest (run: claude-wyvrn update)"
    elif [ -n "$latest" ]; then
      log "latest: $latest (up to date)"
    fi
  fi
}

cmd_version() {
  if [ -f "$INSTALL_DIR/VERSION" ]; then
    tr -d ' \n\r' < "$INSTALL_DIR/VERSION"
    echo
  else
    die "not installed"
  fi
}

cmd_uninstall() {
  rm -rf "$INSTALL_DIR"
  rm -f  "$SHIM"
  log "uninstalled claude-wyvrn"
}

cmd_help() {
  cat <<EOF
claude-wyvrn — Wyvrn Claude harness installer/CLI

Usage: claude-wyvrn <command>

Commands:
  install      Install the harness to ~/.claude-wyvrn/
  update       Update to the latest release (or CLAUDE_WYVRN_VERSION)
  init         Initialize a new project (CLAUDE.md + .claude-wyvrn-local/).
               Auto-preserves any pre-existing CLAUDE.md to PROJECT.md.
  refresh      Re-apply skeleton in an already-initialized project.
               Overwrites CLAUDE.md, additively adds missing dirs/files.
               Never touches PROJECT.md, ARCHITECTURE.md, or artifacts.
  uninit       Inverse of init: restore PROJECT.md as CLAUDE.md and remove
               .claude-wyvrn-local/. Refuses if artifacts present;
               override with --force.
  doctor       Verify install integrity, check for updates
  version      Print installed harness version
  uninstall    Remove ~/.claude-wyvrn/ and CLI shim (global, not per-project)
  help         Show this help

Environment:
  CLAUDE_WYVRN_VERSION   Pin to a release version (e.g. 0.2.1) or 'local' for
                         dev installs from a repo checkout. Default: latest.
EOF
}

main() {
  local cmd="${1:-install}"
  shift || true
  case "$cmd" in
    install)   cmd_install "$@" ;;
    update)    cmd_update "$@" ;;
    init)      cmd_init "$@" ;;
    refresh)   cmd_refresh "$@" ;;
    uninit)    cmd_uninit "$@" ;;
    doctor)    cmd_doctor "$@" ;;
    version|--version|-v) cmd_version ;;
    uninstall) cmd_uninstall "$@" ;;
    help|--help|-h) cmd_help ;;
    *) die "unknown command: $cmd (try: claude-wyvrn help)" ;;
  esac
}

main "$@"
