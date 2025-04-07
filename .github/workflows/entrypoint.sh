#!/bin/sh -l

cf api "$INPUT_CF_API_URL"
cf auth "$INPUT_CF_USER" "$INPUT_CF_PASSWORD"
cf login -u "$INPUT_CF_USER" -p "$INPUT_CF_PASSWORD"
cf install-plugin multiapps -f

if [ -n "$INPUT_CF_ORG" ] && [ -n "$INPUT_CF_SPACE" ]; then
  cf target -o "$INPUT_CF_ORG" -s "$INPUT_CF_SPACE"
fi

sh -c "cf $*"
