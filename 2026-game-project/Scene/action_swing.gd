extends Area2D

@export var damage: float = 1.0


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.call("take_damage", damage)
