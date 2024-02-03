#!/bin/bash

readonly GODOT=/home/mateus/.local/share/godot/app_userdata/Godots/versions/Godot_v4_2_1-stable_linux_x86_64/Godot_v4.2.1-stable_linux.x86_64
readonly PROJECT_DIR=/home/mateus/GitHub/Godot4RoguelikeProject
readonly VERSION=$(sed -nr "/^\[global\]/ { :l /^version[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ${PROJECT_DIR}/project.godot | tr '.' '_' | cut -d "\"" -f 2)
#echo $VERSION

targets=("Linux/X11" "Windows Desktop")
export_name=where_is_the_princess
save_dir=~/Downloads/

export_linux() {
  #echo $save_path
  target_no_slash=$(echo $target | tr '/' '_' )
  target_no_slash=$(echo $target_no_slash | tr ' ' '_')
  game_folder_name=${export_name}_${target_no_slash}
  save_path=${save_dir}${game_folder_name}
  mkdir $save_path
  mv $save_dir$export_name $save_path/${export_name}.x86_64
  mv $save_dir$export_name.pck $save_path/$export_name.pck
  cp ./icon.png ${save_path}/where_is_the_princess.png
  cp ./scripts/install.sh ${save_path}/install.sh
  cp ./scripts/where_is_the_princess.desktop ${save_path}/where_is_the_princess.desktop

  cd ${save_dir}
  tar -cvzf ${export_name}_${VERSION}_lin.tar.gz ${game_folder_name}
  rm -rf $game_folder_name
}

export_windows() {
  target_no_slash=$(echo $target | tr '/' '_' )
  target_no_slash=$(echo $target_no_slash | tr ' ' '_')
  game_folder_name=${export_name}_${target_no_slash}
  save_path=${save_dir}${game_folder_name}
  echo $save_path
  mkdir $save_path
  mv $save_dir$export_name ${save_path}/${export_name}.exe
  mv $save_dir$export_name.pck ${save_path}/${export_name}.pck

  cd ${save_dir}
  zip -v9r ${export_name}_${VERSION}_win.zip ${game_folder_name}
  rm -rf $game_folder_name
}

for ((i = 0; i < ${#targets[@]}; i++)); do
  target=${targets[i]}
  echo Exporting target $target
  cd $PROJECT_DIR
  $GODOT --headless --export-release "$target" $save_dir$export_name
  case $target in

    "Linux/X11")
      export_linux
      ;;
    
    "Windows Desktop")
      export_windows
      ;;
    
    *)
      echo Invalid target $target
      exit 1
      ;;
  esac
done

