extends CanvasLayer

func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/main.tscn")

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/menu.tscn")
