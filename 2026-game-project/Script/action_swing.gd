extends Area2D

@export var damage: float = 1.0
@export var knockback_force: float = 220.0


# When the sword hitbox touches an enemy: damage it and knock it back.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.call("take_damage", damage)
	if body.is_in_group("enemy") and body.has_method("apply_knockback"):
		var push_direction = body.global_position - global_position
		body.call("apply_knockback", push_direction, knockback_force)
