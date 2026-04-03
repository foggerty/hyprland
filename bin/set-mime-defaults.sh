#!/bin/bash
declare -A -r mimeTypes=(
    ["application/json"]="emacsclient.desktop"
    ["application/pdf"]="okularApplication_pdf.desktop"
    ["application/epub+zip"]="com.github.johnfactotum.Foliate.desktop"
    ["application/zip"]="thunar.desktop"
    ["application/x-7z-compressed"]="thunar.desktop"
    ["application/gzip"]="thunar.desktop"
    ["application/x-tar"]="thunar.desktop"
    ["application/x-shellscript"]="emacsclient.desktop"
    ["application/x-zerosize"]="emacsclient.desktop"
    ["application/xml"]="emacsclient.desktop"
    ["application/xml"]="emacsclient.desktop"

    ["image/png"]="org.xfce.ristretto.desktop"
    ["image/jpeg"]="org.xfce.ristretto.desktop"
    ["image/jpg"]="org.xfce.ristretto.desktop"
    ["imagejgif"]="org.xfce.ristretto.desktop"

    ["text/org"]="emacsclient.desktop"
    ["text/plain"]="emacsclient.desktop"
    ["text/markdown"]="emacsclient.desktop"

    ["application/pdf"]="org.gnome.Evince.desktop"
)


for mType in "${!mimeTypes[@]}"; do
    xdg-mime default ${mimeTypes[$mType]} $mType
done
