#!/bin/bash
set -u -e
# Available environment variables
# NGINX_CONFIG, UPSTREAM_BASE, RESTART_CMD_A, RESTART_CMD_B
# Optional:
# VERIFY_CMD_A, VERIFY_CMD_B
die() {
    echo $@
    exit 1
}

VERIFY_CMD_A=${VERIFY_CMD_A:=true}
VERIFY_CMD_B=${VERIFY_CMD_B:=true}

# Find out which page is active _right now_.
active=$(cat $NGINX_CONFIG | grep proxy_pass | grep -o "${UPSTREAM_BASE}[AB]" | sort | uniq)

if [ "$active" == "${UPSTREAM_BASE}A" ]; then
    active=A
    new=B
elif [ "$active" == "${UPSTREAM_BASE}B" ]; then
    active=B
    new=A
else
    die "Failed to determine active group"
fi

echo "Currently active group: $active"

# Restart the new group
echo "Restarting group $new"
rcmd=RESTART_CMD_$new
${!rcmd} || die "Failed to restart group $new"

# Verify the new group
echo "Verifying group $new"
vcmd=VERIFY_CMD_$new
${!vcmd} || die "Failed to verify group $new"

# Switch nginx to use the new group
echo "Updating nginx to $new"
sed -i "s/\(proxy_pass.*\)${UPSTREAM_BASE}[AB]/\1${UPSTREAM_BASE}${new}/g" "$NGINX_CONFIG"

# Test nginx
nginx -t || die "New nginx config is bad"

# Restart nginx
echo "Reloading nginx..."
service nginx reload  # TODO: non-Ubuntu way of doing this?
