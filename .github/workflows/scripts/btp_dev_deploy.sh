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
TOKEN=$(curl -s -X POST -u "$tms_client_id:$tms_client_secret" -d "grant_type=client_credentials&response_type=token" $cf_auth_url/oauth/token | sed -n '/ *"access_token": *"/ {s///; s/{//g ;s/".*//; p; }')
BODY=$(curl -s --location --request POST '$cf_tms_url/v2/files/upload' --header "Authorization: Bearer $TOKEN" --header 'Cookie: JSESSIONID=D11A4F1DE5C6638B18925D58307B360D; __VCAP_ID__=8aa9e193-d2a1-492c-76bc-288a' --form 'file=@"mta_archives/POCGHACTION901_1.mtar"' | awk -F ":" '{print $2}' | grep -Po "\\d+")
curl --location --request POST '$cf_tms_url/v2/nodes/upload' --header 'Content-Type: application/json' --header "Authorization: Bearer $TOKEN" --header 'Cookie: JSESSIONID=D11A4F1DE5C6638B18925D58307B360D; __VCAP_ID__=8aa9e193-d2a1-492c-76bc-288a' --data-raw '{ "nodeName": "DEV_NODE", "contentType": "MTA", "storageType": "FILE", "entries": [ { "uri": '"$BODY"' } ], "description": "TMS DEV MTA Upload", "namedUser": "raviteja.gattu@sap.com" }'

#echo '############## Authorizations ##############'
#cf api $cf_api_url
#cf auth $cf_user "$cf_password"

#echo '############## Deploy ##############'
#cf target -o $cf_org -s $cf_space
#cf deploy mta_archives/POCGHACTION901_1.0.0.mtar -f
