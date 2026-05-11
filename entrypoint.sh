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
  if [ -d "$dir" ]; then
    info "Checking permissions for $dir"
    if [ ! -w "$dir" ]; then
      warn "Directory $dir is not writable, attempting to fix permissions"
      # Try to fix with current user first
      chmod -R u+rw "$dir" 2>/dev/null || true
      
      # If still not writable and we can use sudo, try as root
      if [ ! -w "$dir" ] && command -v sudo >/dev/null 2>&1; then
        warn "Using sudo to fix permissions on $dir"
        sudo chmod -R u+rw "$dir" 2>/dev/null || warn "Still can't fix permissions on $dir"
      fi
    fi
  fi
}

# Check for version command (run silently)
if [ "$1" = "doxygen" ] && [ "$2" = "-v" ]; then
  exec doxygen -v
fi

# Handle privilege drop (always runs when started as root)
if [ "$(id -u)" = "0" ]; then
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

# Check if the command is doxygen and Doxyfile not readable
if [ "$1" = "doxygen" ] && [ -n "$2" ] && [ "$2" != "-v" ] && [ "$2" != "--help" ] && [ ! -r "$2" ]; then
  warn "Doxyfile at $2 is not readable, this may cause issues"
fi

# Special handling for help command
if [ "$1" = "doxygen" ] && [ "$2" = "--help" ]; then
  exec doxygen --help
fi

# Check if running custom command or default
if [ "$#" -eq 0 ]; then
  # No arguments provided, run default command
  info "Running default command: doxygen /Doxyfile"
  exec doxygen /Doxyfile
else
  # Execute the passed command
  info "Running command: $@"
  exec "$@"
fi
