#!/bin/bash

#install stuff
what=${PWD##*/}   
extension=
#peut être extension vide

echo "wmctrl utility is needed.."
sudo pacman -S wmctrl 

echo "Set executable..."
chmod +x $what$extension
#echo "lien symbolique vers usr bin"
sudo ln -s "$PWD/$what$extension" /usr/bin/$what
echo "done."

