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

token=$(curl -s -X POST -u 'sb-f6fc1da5-6ee8-461d-80ff-c718e04af095!b425594|alm-ts-backend!b1603:95cc5e5e-aa7c-4ac2-9f78-c0981ffae4dc$NnYG4dtBEaRyWztI8cmesp-hp74n5v27df8MzOK7anU=' -d "grant_type=client_credentials&response_type=token" https://77658471trial.authentication.us10.hana.ondemand.com/oauth/token | sed -n '/ *"access_token": *"/ {s///; s/{//g ;s/".*//; p; }')
echo $token

body=$(curl -s --location --request POST 'https://transport-service-app-backend.ts.cfapps.us10.hana.ondemand.com/v2/files/upload/v2/files/upload' --header "Authorization: Bearer eyJhbGciOiJSUzI1NiIsImprdSI6Imh0dHBzOi8vNzc2NTg0NzF0cmlhbC5hdXRoZW50aWNhdGlvbi51czEwLmhhbmEub25kZW1hbmQuY29tL3Rva2VuX2tleXMiLCJraWQiOiJkZWZhdWx0LWp3dC1rZXktOTcyZmUyMzk5YyIsInR5cCI6IkpXVCIsImppZCI6ICJnSVNMcmVueHVMWDc3dmRZUHE0TFlXcU9BZ0VjSEJsK2tjNFVwTnpjMjh3PSJ9.eyJqdGkiOiIwNDhkM2M1MzhlYjE0N2I4OTY0MjRhYTU5ZTcyNjZmMCIsImV4dF9hdHRyIjp7ImVuaGFuY2VyIjoiWFNVQUEiLCJzdWJhY2NvdW50aWQiOiI5MjFmY2YwNy03NjJhLTQwODQtODg0Ny0zNWJhYmM1NmU5ZmMiLCJ6ZG4iOiI3NzY1ODQ3MXRyaWFsIiwic2VydmljZWluc3RhbmNlaWQiOiJmNmZjMWRhNS02ZWU4LTQ2MWQtODBmZi1jNzE4ZTA0YWYwOTUifSwic3ViIjoic2ItZjZmYzFkYTUtNmVlOC00NjFkLTgwZmYtYzcxOGUwNGFmMDk1IWI0MjU1OTR8YWxtLXRzLWJhY2tlbmQhYjE2MDMiLCJhdXRob3JpdGllcyI6WyJ1YWEucmVzb3VyY2UiLCJhbG0tdHMtYmFja2VuZCFiMTYwMy5zZXJ2aWNlIl0sInNjb3BlIjpbInVhYS5yZXNvdXJjZSIsImFsbS10cy1iYWNrZW5kIWIxNjAzLnNlcnZpY2UiXSwiY2xpZW50X2lkIjoic2ItZjZmYzFkYTUtNmVlOC00NjFkLTgwZmYtYzcxOGUwNGFmMDk1IWI0MjU1OTR8YWxtLXRzLWJhY2tlbmQhYjE2MDMiLCJjaWQiOiJzYi1mNmZjMWRhNS02ZWU4LTQ2MWQtODBmZi1jNzE4ZTA0YWYwOTUhYjQyNTU5NHxhbG0tdHMtYmFja2VuZCFiMTYwMyIsImF6cCI6InNiLWY2ZmMxZGE1LTZlZTgtNDYxZC04MGZmLWM3MThlMDRhZjA5NSFiNDI1NTk0fGFsbS10cy1iYWNrZW5kIWIxNjAzIiwiZ3JhbnRfdHlwZSI6ImNsaWVudF9jcmVkZW50aWFscyIsInJldl9zaWciOiI3MzNhNzUxMSIsImlhdCI6MTc0NDA5OTcyMiwiZXhwIjoxNzQ0MTQyOTIyLCJpc3MiOiJodHRwczovLzc3NjU4NDcxdHJpYWwuYXV0aGVudGljYXRpb24udXMxMC5oYW5hLm9uZGVtYW5kLmNvbS9vYXV0aC90b2tlbiIsInppZCI6IjkyMWZjZjA3LTc2MmEtNDA4NC04ODQ3LTM1YmFiYzU2ZTlmYyIsImF1ZCI6WyJhbG0tdHMtYmFja2VuZCFiMTYwMyIsInVhYSIsInNiLWY2ZmMxZGE1LTZlZTgtNDYxZC04MGZmLWM3MThlMDRhZjA5NSFiNDI1NTk0fGFsbS10cy1iYWNrZW5kIWIxNjAzIl19.SBa0VV7zq0qUc2k17cIsnL4RLfhLGBpsjjZHb-8LPisxJxN7vSKWyaG6UDE6R11-Xo6-ETKh5B551vv3NOsSpvjTA9DjhQoz9ifmORxHMQ5AWX0sfCv8TRbNG4BrCNssx7NYTnTDyyox6nxnXyEfUZlbOlF6P1vz4GevbFoKKsQNP5vAbPS2s92oRf5T1zOWxf8bCkmRC6sJQXrTQw2yvnmDWGVLFviKmMKQ7uW3_fV5lRZXq6XO6JxIEXfNmGQj9lq0GEvNKD3oCEKm_5YQUKcGXVfl_eCdwN-jGYFx5hTsjgO6xIDUlq7LEOqi7JvSXbJHO6n4Azze0xbbOdrkDw" --form 'file=@"mta_archives/POCGHACTION901_1.mtar"' | awk -F ":" '{print $2}')
echo $body

curl --location --request POST '$cf_tms_url/v2/nodes/upload' --header 'Content-Type: application/json' --header "Authorization: Bearer $token" --header 'Cookie: JSESSIONID=D11A4F1DE5C6638B18925D58307B360D; __VCAP_ID__=8aa9e193-d2a1-492c-76bc-288a' --data-raw '{ "nodeName": "DEV_NODE", "contentType": "MTA", "storageType": "FILE", "entries": [ { "uri": '"$body"' } ], "description": "TMS DEV MTA Upload", "namedUser": "raviteja.gattu@sap.com" }'

#echo '############## Authorizations ##############'
#cf api $cf_api_url
#cf auth $cf_user "$cf_password"

#echo '############## Deploy ##############'
#cf target -o $cf_org -s $cf_space
#cf deploy mta_archives/POCGHACTION901_1.0.0.mtar -f
