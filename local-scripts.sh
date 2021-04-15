#!/bin/bash

# Function to read input from user with a prompt
# Credits: https://github.com/TheRemote/MinecraftBedrockServer/blob/1f27b8ab82f920bb967d1c27ee2fd120a484c99c/SetupMinecraft.sh
function read_with_prompt {
  variable_name="$1"
  prompt="$2"
  default="${3-}"
  unset $variable_name
  while [[ ! -n ${!variable_name} ]]; do
    read -p "$prompt: " $variable_name < /dev/tty
    if [ ! -n "`which xargs`" ]; then
      declare -g $variable_name=$(echo "${!variable_name}" | xargs)
    fi
    declare -g $variable_name=$(echo "${!variable_name}" | head -n1 | awk '{print $1;}')
    if [[ -z ${!variable_name} ]] && [[ -n "$default" ]] ; then
      declare -g $variable_name=$default
    fi
    echo -n "$prompt : ${!variable_name} -- accept (y/n)?"
    read answer < /dev/tty
    if [ "$answer" == "${answer#[Yy]}" ]; then
      unset $variable_name
    else
      echo "$prompt: ${!variable_name}"
    fi
  done
}

function read_yes_no {
  variable_name="$1"
  prompt="$2"
  unset $variable_name

  read -p "$prompt -- (y/n)?" answer
  case ${answer:0:1} in
      y|Y )
          declare -g $variable_name=true
      ;;
      * )
          declare -g $variable_name=false
      ;;
  esac
}
