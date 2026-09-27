extends Node2D

# Constants
const INPUT_SKILL_ONE := "Skill_one"
const INPUT_SKILL_TWO := "Skill_two"
const TERRAIN_SET := 0
const DIRT_TERRAIN := 1
const SKILL_ONE := 1
const SKILL_TWO := 2

@export var terrain_layer: TileMapLayer
@export var skillone: Button
@export var skilltwo: Button
@export var scene_skillone: PackedScene
@export var scene_skilltwo: PackedScene
@export var skill_one_cooldown: float = 3.0
@export var skill_two_cooldown: float = 2.0

var skill_one_ready: bool = true
var skill_two_ready: bool = true
@export var player: CharacterBody2D
@export var ice_sound: AudioStreamPlayer
@export var fire_sound: AudioStreamPlayer
@export var spawner: Path2D
@export var music: AudioStreamPlayer
@export var boss_music: AudioStreamPlayer


# At start: fix the dirt tile edges and tell the player where the map ends.
func _ready() -> void:
	var dirt_cells: Array[Vector2i] = []
	for cell in terrain_layer.get_used_cells():
		var tile_data := terrain_layer.get_cell_tile_data(cell)
		if tile_data != null and tile_data.terrain == DIRT_TERRAIN:
			dirt_cells.append(cell)
	if not dirt_cells.is_empty():
		terrain_layer.set_cells_terrain_connect(dirt_cells, TERRAIN_SET, DIRT_TERRAIN)

	var map_rect = terrain_layer.get_used_rect()
	var tile_size = terrain_layer.tile_set.tile_size
	var top_left = Vector2(map_rect.position * tile_size)
	var bottom_right = Vector2(map_rect.end * tile_size)
	player.set_map_limits(top_left, bottom_right)


# Every frame: check the skill keys and play the right music for the wave.
func _process(delta: float) -> void:
	use_skill()
	update_music()


# Plays the boss music during a boss wave and the normal music the rest of the time.
func update_music() -> void:
	if spawner.is_boss_wave and not boss_music.playing:
		music.stop()
		boss_music.play()
	elif not spawner.is_boss_wave and not music.playing:
		boss_music.stop()
		music.play()


# Casts a skill when its key (Q or E) is pressed and it is ready.
func use_skill() -> void:
	if Input.is_action_just_pressed(INPUT_SKILL_ONE) and skill_one_ready:
		_on_skill_1_pressed()
	if Input.is_action_just_pressed(INPUT_SKILL_TWO) and skill_two_ready:
		_on_skill_2_pressed()


# Skill 1 (ice): spawn the burst on the player and play the ice sound.
func _on_skill_1_pressed() -> void:
	if not skill_one_ready:
		return
	var skill = scene_skillone.instantiate()
	skill.damage += player.skill_damage_bonus
	add_child(skill)
	skill.global_position = player.global_position
	ice_sound.play()
	start_cooldown(SKILL_ONE)


# Skill 2 (fire): spawn the strike in the direction the player faces and play the fire sound.
func _on_skill_2_pressed() -> void:
	if not skill_two_ready:
		return
	var skill = scene_skilltwo.instantiate()
	skill.damage += player.skill_damage_bonus
	add_child(skill)
	skill.global_position = player.global_position
	skill.rotation = player.last_direction.angle()
	fire_sound.play()
	start_cooldown(SKILL_TWO)


# Blocks a skill and greys out its button until its cooldown time has passed.
func start_cooldown(skill_index: int) -> void:
	if skill_index == SKILL_ONE:
		skill_one_ready = false
		if skillone:
			skillone.disabled = true
		await get_tree().create_timer(skill_one_cooldown).timeout
		skill_one_ready = true
		if skillone:
			skillone.disabled = false
	else:
		skill_two_ready = false
		if skilltwo:
			skilltwo.disabled = true
		await get_tree().create_timer(skill_two_cooldown).timeout
		skill_two_ready = true
		if skilltwo:
			skilltwo.disabled = false
