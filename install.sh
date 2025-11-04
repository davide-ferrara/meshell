#!/bin/bash

echo "Questo linkerá lab.sh in /bin per renderlo eseguibile..."

origin="$(pwd)/meshell.sh"
dest="/usr/local/bin/meshell"

sudo ln -sf "$origin" "$dest"
sudo mv bin/* /usr/local/bin

echo "meshell é stato installato!"
echo "Esegui meshell --h per visualizzare i comandi."
