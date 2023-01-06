#!/usr/bin/bash
# Dump the netbox database into a file
docker exec -i netbox-docker_postgres_1 pg_dump --username netbox --host localhost netbox  > netbox_`date +%s`.sql
