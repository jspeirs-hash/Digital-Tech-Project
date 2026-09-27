extends Path2D

@export var enemy_scene: PackedScene
@export var spawn_time: float = 1.0
@export var enemies_per_wave: int = 3
@export var wave_growth: int = 2
@export var time_between_waves: float = 3.0
@export var health_growth: float = 0.5
@export var follow: PathFollow2D
@export var player: CharacterBody2D
@export var heal_per_wave: float = 3.0

#boss
@export var boss_every: int = 5
@export var boss_scale: float = 2.5
@export var boss_health_multiplier: float = 6.0
@export var boss_speed_multiplier: float = 0.8
@export var boss_damage_multiplier: float = 2.0

var timer: float = 0.0
var wave_timer: float = 0.0
var wave_number: int = 0
var enemies_to_spawn: int = 0
var is_boss_wave: bool = false

# Starts wave 1 when the game begins.
func _ready() -> void:
	start_next_wave()

# Spawns this wave's enemies one at a time; when all are dead, waits, then starts the next wave.
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

# Moves to the next wave, heals the player (from wave 2 on), works out how many enemies it has, and updates the wave text.
# Every boss_every waves it is a boss wave with one giant slime.
func start_next_wave() -> void:
	wave_number += 1
	if wave_number > 1:
		player.heal(heal_per_wave)
	is_boss_wave = wave_number % boss_every == 0

	var label = get_tree().current_scene.get_node("HUD/WaveLabel")
	if is_boss_wave:
		enemies_to_spawn = 1
		label.text = "Boss Wave " + str(wave_number) + "!"
	else:
		enemies_to_spawn = enemies_per_wave + (wave_number - 1) * wave_growth
		label.text = "Wave " + str(wave_number)

# Spawns one enemy at a random point on the path around the player, with more health each wave.
func spawn_enemy() -> void:
	if curve == null or curve.point_count < 2:
		return

	follow.progress_ratio = randf_range(0.0, 1.0)

	var enemy = enemy_scene.instantiate()
	enemy.health += (wave_number - 1) * health_growth
	if is_boss_wave:
		make_boss(enemy)
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = follow.global_position

# Turns a normal slime into the boss: bigger, much more health, slower, harder hits, and a longer reach to match its size.
func make_boss(enemy) -> void:
	enemy.scale = Vector2(boss_scale, boss_scale)
	enemy.health *= boss_health_multiplier
	enemy.speed *= boss_speed_multiplier
	enemy.attack_damage *= boss_damage_multiplier
	enemy.attack_range *= boss_scale
