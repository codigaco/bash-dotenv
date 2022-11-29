#!/bin/sh

output=".env.output"
env=""

while getopts ":o:e:" option; do
  case $option in
  o)
    output=$OPTARG
    ;;
  e)
    env=$OPTARG
    ;;
  *)
    echo "Error: Invalid option"
    exit
    ;;
  esac
done

if [ -z "$env" ] && [ -f '.env.local' ]; then
  env=$(grep -E "^APP_ENV=(.*)" ".env.local" | cut -d "=" -f 2)
fi

if [ -z "$env" ] && [ -f '.env' ]; then
  env=$(grep -E "^APP_ENV=(.*)" ".env" | cut -d "=" -f 2)
fi

dotEnvs=".env .env.local"

if [ -n "$env" ]; then
  dotEnvs="$dotEnvs .env.${env} .env.${env}.local"
fi

echo "# ENV (${env}) MERGED" >"$output"

readEnvVariables() {
  if [ ! -f "$1" ]; then
    return
  fi

  while read -r line; do
    if [ -z "${line%%#*}" ]; then
      continue
    fi

    varName=$(echo "$line" | awk -F '=' '{print $1}')

    if [ "$(cat "$output" | grep -E "${varName}=")" ]; then
      sed -i "s/^${varName}=.*/${line}/g" "$output"
      continue
    fi

    echo "$line" >>"$output"
  done <"$1"
}

for dotEnv in ${dotEnvs}; do
  readEnvVariables "${dotEnv}"
done
