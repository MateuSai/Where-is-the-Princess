#!bin/sh

SETTINGS_PATH=~/.local/share/godot/app_userdata/Godot4RoguelikeProject/settings.cfg
echo "Trying to delete $SETTINGS_PATH"
if [ -f "$SETTINGS_PATH" ]; then
    rm $SETTINGS_PATH
    echo "Settings removed!"
else
    echo "There is no settings yet!"
fi
