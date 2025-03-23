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

    ["image/png"]="feh.desktop"
    ["image/jpeg"]="feh.desktop"
    ["image/jpg"]="feh.desktop"
    ["imagejgif"]="feh.desktop"

    ["text/org"]="emacsclient.desktop"
    ["text/plain"]="emacsclient.desktop"
)


for mType in "${!mimeTypes[@]}"; do
    xdg-mime default ${mimeTypes[$mType]} $mType
done

echo $LANG | cut -f2 -d= | cut -f1 -d. > ~/.config/user-dirs.locale
