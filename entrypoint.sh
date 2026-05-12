#!/bin/sh
set -e

# Function to output info messages - always to stderr
info() {
  echo "[INFO] $@" >&2
}

# Function to output warning messages
warn() {
  echo "[WARN] $@" >&2
}

# Function to fix permissions on a directory
fix_permissions() {
  local dir=$1
  if [ ! -d "$dir" ]; then
    warn "Directory $dir does not exist — skipping permission check (doxygen may fail)"
    return
  fi
  if [ ! -w "$dir" ]; then
    warn "Directory $dir is not writable, attempting to fix permissions"
    chmod -R u+rw "$dir" || warn "chmod failed on $dir — doxygen may fail to write output"
  fi
}

# Check for version command (run silently)
if [ "$1" = "doxygen" ] && [ "$2" = "-v" ]; then
  exec doxygen -v
fi

# Handle privilege drop (always runs when started as root)
if [ "$(id -u)" = "0" ]; then
  if { [ -n "$PUID" ] && [ -z "$PGID" ]; } || { [ -z "$PUID" ] && [ -n "$PGID" ]; }; then
    warn "Both PUID and PGID must be set for remapping — ignoring partial values (PUID=${PUID:-unset} PGID=${PGID:-unset})"
  fi
  if [ -n "$PUID" ] && [ -n "$PGID" ]; then
    info "Remapping doxygen UID:GID to $PUID:$PGID"
    if [ -f /etc/alpine-release ]; then
      # Alpine
      deluser doxygen 2>/dev/null && info "Removed existing doxygen user" || true
      delgroup doxygen 2>/dev/null && info "Removed existing doxygen group" || true
      addgroup -g "$PGID" doxygen
      adduser -u "$PUID" -G doxygen -s /bin/sh -D -h /home/doxygen doxygen
    elif [ -f /etc/debian_version ]; then
      # Debian
      groupmod -o -g "$PGID" doxygen
      usermod -o -u "$PUID" doxygen
    fi
    chown -R doxygen:doxygen /home/doxygen
  fi

  if command -v su-exec >/dev/null 2>&1; then
    exec su-exec doxygen "$0" "$@"
  elif command -v gosu >/dev/null 2>&1; then
    info "su-exec not available, using gosu for privilege drop"
    exec gosu doxygen "$0" "$@"
  else
    warn "Neither su-exec nor gosu found, falling back to su (args with spaces may break)"
    exec su -p doxygen -c "$0 $*"
  fi
fi

# Check critical directories for permissions issues
fix_permissions /input
fix_permissions /output

# Abort early if the specified config file is not readable — doxygen will always fail
if [ "$1" = "doxygen" ] && [ -n "$2" ] && [ "$2" != "-v" ] && [ "$2" != "--help" ] && [ ! -r "$2" ]; then
  echo "[ERROR] Doxyfile '$2' is not readable. Check that the file exists and the container has read permission." >&2
  exit 1
fi

# Special handling for help command
if [ "$1" = "doxygen" ] && [ "$2" = "--help" ]; then
  exec doxygen --help
fi

# When doxygen is run without a config path, try /Doxyfile first then fall back to /Doxygen
if [ "$1" = "doxygen" ] && [ "$#" -eq 1 ] || [ "$#" -eq 0 ]; then
  if [ -f /Doxyfile ]; then
    exec doxygen /Doxyfile
  elif [ -f /Doxygen ]; then
    warn "Mounting config at /Doxygen is deprecated — please rename your mount to /Doxyfile"
    exec doxygen /Doxygen
  else
    exec doxygen /Doxyfile
  fi
fi

exec "$@"
