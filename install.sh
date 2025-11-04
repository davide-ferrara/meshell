#!/bin/bash

echo "Questo linkerá lab.sh in /bin per renderlo eseguibile..."

origin="$(pwd)/meshell.sh"
dest="/usr/local/bin/meshell"

sudo ln -sf "$origin" "$dest"
for f in bin/*; do
  sudo ln -sf "$(pwd)/$f" "/usr/local/bin/$(basename "$f")"
done

echo "meshell é stato installato!"
echo "Esegui meshell --h per visualizzare i comandi."
