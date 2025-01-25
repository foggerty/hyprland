#!/bin/bash
declare -A -r mimeTypes=(
    ["application/json"]="emacsclient.desktop"
    ["application/pdf"]="com.github.johnfactotum.Foliate.desktop"
    ["application/zip"]="thunar.desktop"
    ["application/x-7z-compressed"]="thunar.desktop"
    ["application/gzip"]="thunar.desktop"
    ["application/x-tar"]="thunar.desktop"
    ["application/x-shellscript"]="emacsclient.desktop"
    ["application/x-zerosize"]="emacsclient.desktop"
    ["application/xml"]="emacsclient.desktop"
    ["application/xml"]="emacsclient.desktop"

    ["image/png"]="swayimg.desktop"
    ["image/jpeg"]="swayimg.desktop"
    ["image/jpg"]="swayimg.desktop"
    ["imagejgif"]="swayimg.desktop"

    ["text/org"]="emacsclient.desktop"
    ["text/plain"]="emacsclient.desktop"
)


for mType in "${!mimeTypes[@]}"; do
    xdg-mime default ${mimeTypes[$mType]} $mType
done
