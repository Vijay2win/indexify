#!/bin/bash

echo "Starting database migration $DATABASE_URL"
# Setup schema
until /indexify/migration up -u $DATABASE_URL
do
  echo "Trying to apply schema again in 5 seconds...."
  sleep 5s
done

# Srart server
/indexify/indexify start-server -c ./config/indexify.yaml
