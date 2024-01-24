#!/bin/sh

readonly GODOT=/home/mateus/.local/share/godot/app_userdata/Godots/versions/Godot_v4_2_1-stable_linux_x86_64/Godot_v4.2.1-stable_linux.x86_64
readonly PROJECT_DIR=/home/mateus/GitHub/Godot4RoguelikeProject

target=${1:-"Linux/X11"}
target_no_slash=$(echo $target | tr '/' '_' )
export_name=where_is_the_princess
save_dir=~/Downloads/
save_path=${save_dir}${export_name}_${target_no_slash}

cd $PROJECT_DIR
$GODOT --headless --export-release $target $save_dir$export_name

echo $save_path
mkdir $save_path
mv $save_dir$export_name $save_path/$export_name
mv $save_dir$export_name.pck $save_path/$export_name.pck
