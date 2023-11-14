#!bin/sh

SAVED_DATA_PATH=~/.local/share/godot/app_userdata/Godot4RoguelikeProject/data.json
echo "Trying to delete $SAVED_DATA_PATH"
if [ -f "$SAVED_DATA_PATH" ]; then
    rm $SAVED_DATA_PATH
    echo "Saved data removed!"
else
    echo "There is no saved data yet!"
fi
