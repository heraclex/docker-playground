#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
set -e
# set -eux

#
# Always install local overrides first
#
# /app/docker/docker-bootstrap.sh

STEP_CNT=3

echo_step() {
cat <<EOF
######################################################################
Init Step ${1}/${STEP_CNT} [${2}] -- ${3}
######################################################################
EOF
}

ADMIN_PASSWORD="admin"
POSTGRESDB_HOST="postgres-db"
$CYPRESS_CONFIG='true'

### STEP1: Initialize the database
echo_step "1" "Starting" "Applying DB migrations"
superset db upgrade
echo_step "1" "Complete" "Applying DB migrations"

### STEP2: Create an admin user
echo_step "2" "Starting" "Setting up admin user ( admin / $ADMIN_PASSWORD )"
superset fab create-admin \
              --username admin \
              --firstname Superset \
              --lastname Admin \
              --email admin@superset.com \
              --password $ADMIN_PASSWORD
echo_step "2" "Complete" "Setting up admin user"

### STEP3: Create default roles and permissions
echo_step "3" "Starting" "Setting up roles and perms"
superset init
echo_step "3" "Complete" "Setting up roles and perms"

### STEP4: Create default roles and permissions
echo_step "4" "Starting" "Loading examples"
# If Cypress run which consumes superset_test_config – load required data for tests
if [ "$CYPRESS_CONFIG" == "true" ]; then
    superset load_test_users
    superset load_examples --load-test-data
else
    superset load_examples
fi
echo_step "4" "Complete" "Loading examples"

/app/docker/docker-bootstrap.sh 'app-gunicorn'