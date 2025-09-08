#!/usr/bin/env bash

if [[ -z "${VAULTWARDEN_VERSION}" ]]; then
  VAULTWARDEN_VERSION="1.34.3"
fi

temp_dir=$(mktemp -d)

# Copy fixtures db to tmp
cp tests/fixtures/server/* $temp_dir

# Set env variables
set -a; . tests/e2e/.env; set +a


# Start Vaultwarden docker
docker run -d --name vaultwarden -v $temp_dir:/data --env INVITATIONS_ALLOWED=${VAULTWARDEN_INVITATIONS_ALLOWED:-false} --env I_REALLY_WANT_VOLATILE_STORAGE=true --env ADMIN_TOKEN=${VAULTWARDEN_ADMIN_TOKEN}  --restart unless-stopped -p 80:7777 vaultwarden/server:${VAULTWARDEN_VERSION}

exit 0

# Wait for vaultwarden to start
sleep 3

# Run tests
hatch run  test:with-coverage

# store the exit code
TEST_EXIT_CODE=$?

# Stop and remove vaultwarden docker
docker stop vaultwarden
docker rm vaultwarden

# Remove fixtures db from tmp
rm -rf $temp_dir

# Exit with the test exit code
exit $TEST_EXIT_CODE