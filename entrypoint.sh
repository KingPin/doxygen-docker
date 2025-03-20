#!/bin/sh
set -e

# Function to output info messages
info() {
  echo "[INFO] $@"
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

# Check for custom user/group IDs
if [ -n "$PUID" ] && [ -n "$PGID" ]; then
  info "Running with custom UID:GID - $PUID:$PGID"
  
  # Check if we're root (can modify user/group)
  if [ "$(id -u)" = "0" ]; then
    # Check if we need to modify the doxygen user/group
    if [ -f /etc/alpine-release ]; then
      # Alpine
      deluser doxygen 2>/dev/null || true
      delgroup doxygen 2>/dev/null || true
      addgroup -g "$PGID" doxygen
      adduser -u "$PUID" -G doxygen -s /bin/sh -D doxygen
    elif [ -f /etc/debian_version ]; then
      # Debian
      groupmod -o -g "$PGID" doxygen
      usermod -o -u "$PUID" doxygen
    fi
    
    # Fix home directory ownership
    chown -R doxygen:doxygen /home/doxygen
    
    # Drop to the doxygen user for the rest of the script
    exec su-exec doxygen "$0" "$@" 2>/dev/null || exec gosu doxygen "$0" "$@" 2>/dev/null || exec su -p doxygen -c "$0 $*"
  fi
fi

# Check critical directories for permissions issues
fix_permissions /input
fix_permissions /output

# Check if the command is doxygen and Doxyfile not readable
if [ "$1" = "doxygen" ] && [ -n "$2" ] && [ ! -r "$2" ]; then
  warn "Doxyfile at $2 is not readable, this may cause issues"
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
