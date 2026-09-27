extends CanvasLayer

# Constants
const GAME_SCENE := "res://Scene/main.tscn"
const MENU_SCENE := "res://Scene/menu.tscn"


# Retry button: restart the game.
func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


# Menu button: go back to the main menu.
func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
