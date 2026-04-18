#copy the config installed from github to their place

CONFIG_DIR="$HOME/.config/"

installed_config="$HOME/config/"

configs=("waybar" "Kvantum" "fastfetch" "kitty" "hypr" "rofi")

echo " starting transfert ..."

for folder in ${configs[@]}; do
  if [ -d "$installed_config/$folder" ]; then
    cp -rf "$installed_config/$folder" "$CONFIG_DIR/"
    echo " Moved $folder"
  else
    echo " Warning: $folder not found in $installed_config"
  fi
done

echo "────────────────────────────────────────────────────────────"

echo " finished"
