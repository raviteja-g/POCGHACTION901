#!/bin/bash
set -e

echo '############## Get cf Client ##############'
wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
sudo apt-get update
sudo apt-get install cf8-cli

echo '############## Check Installation ##############'
cf -v

echo '############## Install Plugins ##############'
cf add-plugin-repo CF-Community https://plugins.cloudfoundry.org
cf install-plugin multiapps -f
cf install-plugin html5-plugin -f

echo '############## Build ##############'
npx mbt build --mtar POCGHACTION901_1.0.0.mtar

echo '############## Upload to CTMS ##############'

token=$(curl -v -s -X POST -u 'sb-f6fc1da5-6ee8-461d-80ff-c718e04af095!b425594|alm-ts-backend!b1603:95cc5e5e-aa7c-4ac2-9f78-c0981ffae4dc$NnYG4dtBEaRyWztI8cmesp-hp74n5v27df8MzOK7anU=' -d "grant_type=client_credentials&response_type=token" https://77658471trial.authentication.us10.hana.ondemand.com/oauth/token | sed -n '/ *"access_token": *"/ {s///; s/{//g ;s/".*//; p; }')
echo $token

body=$(curl -s --location --request POST 'https://transport-service-app-backend.ts.cfapps.us10.hana.ondemand.com/v2/files/upload' --header "Authorization: Bearer $token" --form 'file=@"/home/runner/work/POCGHACTION901/POCGHACTION901/mta_archives/POCGHACTION901_1.0.0.mtar"' | jq -r '.fileId')
echo $body

response=$(curl --location --request POST 'https://transport-service-app-backend.ts.cfapps.us10.hana.ondemand.com/v2/nodes/upload' --header 'Content-Type: application/json' --header "Authorization: Bearer $token" --data-raw '{ "nodeName": "DEV_NODE", "contentType": "MTA", "storageType": "FILE", "entries": [ { "uri": '"$body"' } ], "description": "TMS DEV MTA Upload", "namedUser": "raviteja.gattu@sap.com" }')
echo $response

#transportRequestId=echo $response | jq -r '.transportRequestId'
echo '############## transportRequestId ##############'
echo $response | jq -r '.transportRequestId'
transportRequestId=$(echo $response | jq -r '.transportRequestId')

#queueEntries=echo $response | jq -r '.queueEntries'
echo '############## queueEntries ##############'
echo $response | jq -r '.queueEntries'
queueEntries=$(echo $response | jq -r '.queueEntries')

#nodeId=echo $queueEntries | jq -r '.queueEntries[0].nodeId'
echo '############## nodeId ##############'
echo $response | jq -r '.queueEntries[0].nodeId'
nodeId=$(echo $response | jq -r '.queueEntries[0].nodeId')

curl -v --location --request POST 'https://transport-service-app-backend.ts.cfapps.us10.hana.ondemand.com/v2/nodes/+'"$nodeId"'+/transportRequests/import' --header 'Content-Type: application/json' --header "Authorization: Bearer $token" --data-raw '{ "namedUser": "raviteja.gattu@sap.com", "transportRequests": [{ '"$transportRequestId"' }]}'
echo '############## Importing Success  ##############'


#echo '############## Authorizations ##############'
#cf api $cf_api_url
#cf auth $cf_user "$cf_password"

#echo '############## Deploy ##############'
#cf target -o $cf_org -s $cf_space
#cf deploy mta_archives/POCGHACTION901_1.0.0.mtar -f
