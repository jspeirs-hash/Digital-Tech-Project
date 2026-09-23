extends Path2D

@export var enemy_scene: PackedScene
@export var spawn_time: float = 1.0

var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	if timer >= spawn_time:
		timer = 0.0
		spawn_enemy()

func spawn_enemy() -> void:
	if curve == null or curve.point_count < 2:
		return

	var follow = $PathFollow2D
	follow.progress_ratio = randf_range(0.0, 1.0)

	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = follow.global_position
