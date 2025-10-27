#!/bin/bash

help="Usage: $0 [start <vm_name>|start all|stop <vm_name>|status|ls|ssh <vm_name>|--h]"
lab_machines=("lab1" "lab2" "lab3" "lab4")

# Ensure at least one argument
if [[ $# -lt 1 ]]; then
  echo "$help"
  exit 1
fi

case "$1" in

"start")
  if [[ -z "$2" ]]; then
    echo "Usage: $0 start <vm_name>|all"
    exit 1
  fi

  if [[ "$2" == "all" ]]; then
    echo "Starting all VMs..."
    for vm in "${lab_machines[@]}"; do
      echo "Starting $vm..."
      VBoxManage startvm "$vm" --type headless
    done
  else
    echo "Starting VM: $2"
    VBoxManage startvm "$2" --type headless
  fi
  ;;

"stop")
  if [[ -z "$2" ]]; then
    echo "Usage: $0 stop <vm_name>|all"
    exit 1
  fi

  if [[ "$2" == "all" ]]; then
    echo "Stopping all VMs..."
    for vm in "${lab_machines[@]}"; do
      echo "Stopping $vm..."
      VBoxManage controlvm "$vm" acpipowerbutton
    done
  else
    echo "Stopping VM: $2"
    VBoxManage controlvm "$2" acpipowerbutton
  fi
  ;;

"status")
  echo "Currently running VMs:"
  VBoxManage list runningvms
  ;;

"ls")
  echo "Available VMs:"
  VBoxManage list vms
  ;;

"rm")
  echo "INOP"
  ;;

"--h" | "--help" | "help")
  echo "$help"
  ;;

*)
  echo "$help"
  ;;
esac

# Docker Version
# help="Usage: $0 [build|run|stop|ls|attach <container_name>|--rm <container_name>|--h]"
# lab_machines=("lab1","lab2","lab3","lab4")
#
# for i in $@; do
#   case $i in
#
#   "build")
#     docker build -t lab-ubuntu:22.04 .
#     ;;
#
#   "run")
#     docker compose up -d
#     ;;
#
#   "stop")
#     docker compose down
#     ;;
#
#   "ls")
#     docker ps
#     ;;
#
#   "exec")
#     if [[ $3 == "--root" ]]; then
#       docker exec -it -u root $2 bash
#     elif [[ $3 == "--admin" ]]; then
#       docker exec -it -u admin $2 bash
#     else
#       docker exec -it $2 bash
#     fi
#     ;;
#
#   "rm")
#     if [[ "$2" == "all" ]]; then
#       docker rm -f $(docker ps -a --filter "name=lab" -q)
#     else
#       found=0
#       for i in "${lab_machines[@]}"; do
#         if [[ "$i" == "$2" ]]; then
#           docker rm -f "$2"
#           found=1
#           break
#         fi
#       done
#       if [[ $found -eq 0 ]]; then
#         echo "Usage: $0 --rm <container_name>"
#       fi
#     fi
#     ;;
#
#   "--h")
#     echo $help
#     ;;
#
#   *)
#     echo $help
#     ;;
#   esac
# done
