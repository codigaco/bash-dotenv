#!/bin/sh

output=".env.output"
envName="dev"

if [ "$1" ]; then
  output="$1"
fi

if [ "$2" ]; then
  envName="$2"
fi

ENVS=".env .env.local .env.${envName} .env.${envName}.local"

echo "# ENV (${envName}) MERGED" > "$output"

readEnvVariables() {
  if [ ! -f "$1" ]; then
    return
  fi

  while read -r line;
  do
    if [ -z "${line%%#*}" ]; then
      continue
    fi

    varName=$(echo "$line" | awk -F '=' '{print $1}')

    if [ "$(cat "$output" | grep -E "${varName}=")" ]; then
      sed -i "s/^${varName}=.*/${line}/g" "$output"
      continue
    fi

    echo "$line" >> "$output";
  done < "$1"
}

for env in ${ENVS}; do
#  printf "${env} \n"
  readEnvVariables "${env}";
done
