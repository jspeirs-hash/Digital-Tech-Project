extends CanvasLayer

# Constants
const GAME_SCENE := "res://Scene/main.tscn"


# Play button: start the game.
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


# Quit button: close the game.
func _on_quit_button_pressed() -> void:
	get_tree().quit()
