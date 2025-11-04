#!/bin/bash

echo "Questo linkerá lab.sh in /bin per renderlo eseguibile..."

origin="$(pwd)/meshell.sh"
dest="/bin/meshell"

sudo ln -sf "$origin" "$dest"
cd scripts/
make
make install

echo "meshell é stato installato!"
echo "Esegui meshell --h per visualizzare i comandi."
