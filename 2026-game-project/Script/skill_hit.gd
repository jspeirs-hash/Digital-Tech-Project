extends Area2D

# Constants
const ENEMY_GROUP := "enemy"

@export var damage: float = 2.0
@export var lifetime: float = 0.6


# Starts listening for hits, then deletes the skill after its lifetime.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	queue_free()


# Damages any enemy the skill touches.
func _on_body_entered(body) -> void:
	if body.is_in_group(ENEMY_GROUP):
		body.take_damage(damage)
