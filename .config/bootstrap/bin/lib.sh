#!/usr/bin/env bash

GREEN="\033[0;32m"
NO_COLOR="\033[0m"

info() {
    echo -e "$GREEN$1$NO_COLOR"
}

run() {
    while true; do
        read -p "$1" yn
        case $yn in
            [Yy] )
                $2; break;;
            [Nn] )
                break;;
        esac
    done
}
