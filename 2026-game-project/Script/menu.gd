extends CanvasLayer

# Play button: start the game.
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/main.tscn")

# Quit button: close the game.
func _on_quit_button_pressed() -> void:
	get_tree().quit()
