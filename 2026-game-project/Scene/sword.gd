extends Node2D

@export var orbit_radius: float = 5.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var global_mouse_pos = get_global_mouse_position()
	
	var dir_mouse = (global_mouse_pos - get_parent().global_position).normalized()
	rotation = dir_mouse.angle()
	
	position = dir_mouse * orbit_radius
