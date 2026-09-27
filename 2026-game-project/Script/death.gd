extends CanvasLayer

# Retry button: restart the game.
func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/main.tscn")

# Menu button: go back to the main menu.
func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/menu.tscn")
