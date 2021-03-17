#!/bin/sh
# Deploy my dotfiles
echo "Copying files to $HOME..."
cp ./bashrc $HOME/.bashrc
cp ./gitconfig $HOME/.gitconfig
cp ./gitignore $HOME/.gitignore
cp ./psqlrc $HOME/.psqlrc
echo "...complete"
echo "Copy login.sql by hand if needed"
