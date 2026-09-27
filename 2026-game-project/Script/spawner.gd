extends Path2D

@export var enemy_scene: PackedScene
@export var spawn_time: float = 1.0
@export var enemies_per_wave: int = 3
@export var wave_growth: int = 1
@export var time_between_waves: float = 3.0

var timer: float = 0.0
var wave_timer: float = 0.0
var wave_number: int = 0
var enemies_to_spawn: int = 0

func _ready() -> void:
	start_next_wave()

func _process(delta: float) -> void:
	if enemies_to_spawn > 0:
		timer += delta
		if timer >= spawn_time:
			timer = 0.0
			spawn_enemy()
			enemies_to_spawn -= 1
	elif get_tree().get_nodes_in_group("enemy").size() == 0:
		wave_timer += delta
		if wave_timer >= time_between_waves:
			wave_timer = 0.0
			start_next_wave()

func start_next_wave() -> void:
	wave_number += 1
	enemies_to_spawn = enemies_per_wave + (wave_number - 1) * wave_growth

	var label = get_tree().current_scene.get_node("HUD/WaveLabel")
	label.text = "Wave " + str(wave_number)

func spawn_enemy() -> void:
	if curve == null or curve.point_count < 2:
		return

	var follow = $PathFollow2D
	follow.progress_ratio = randf_range(0.0, 1.0)

	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = follow.global_position
