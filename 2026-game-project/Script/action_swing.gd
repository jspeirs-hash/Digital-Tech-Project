extends Area2D

# Constants
const ENEMY_GROUP := "enemy"

@export var damage: float = 1.0
@export var knockback_force: float = 120.0


# When the sword hitbox touches an enemy: damage it and knock it back.
func _on_body_entered(body) -> void:
	if body.is_in_group(ENEMY_GROUP):
		body.take_damage(damage)
		var push_direction = body.global_position - global_position
		body.apply_knockback(push_direction, knockback_force)
