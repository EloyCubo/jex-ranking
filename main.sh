#!/bin/bash

if (( $EUID != 0 )); then
    printf "\033[0;33m<jex-ranking> \033[0;31m[✕]\033[0m Please run this program as root \n"
    exit
fi

echo "This program is free software: you can redistribute it and/or modify."
echo "[1] Install module"
echo "[2] Delete module"
echo "[3] Exit"
echo ""

read -p "<jex-ranking> [?] Please enter a number: " choice
if [ "$choice" == "1" ]; then
    bash ./install.sh
fi
if [ "$choice" == "2" ]; then
    bash ./delete.sh
fi
if [ "$choice" == "3" ]; then
    exit
fi