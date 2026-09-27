extends Node2D

@onready var terrain_layer: TileMapLayer = $Map/Main
@export var skillone: Button
@export var skilltwo: Button
@export var scene_skillone: PackedScene
@export var scene_skilltwo: PackedScene
@export var skill_one_cooldown: float = 3.0
@export var skill_two_cooldown: float = 2.0

var skill_one_ready: bool = true
var skill_two_ready: bool = true
@export var player: CharacterBody2D

func _ready() -> void:
	var dirt_cells: Array[Vector2i] = []
	for cell in terrain_layer.get_used_cells():
		var tile_data := terrain_layer.get_cell_tile_data(cell)
		if tile_data != null and tile_data.terrain == 1:
			dirt_cells.append(cell)
	if not dirt_cells.is_empty():
		terrain_layer.set_cells_terrain_connect(dirt_cells, 0, 1)

func _process(delta: float) -> void:
	use_skill()

func use_skill() -> void:
	if Input.is_action_just_pressed("Skill_one") and skill_one_ready:
		_on_skill_1_pressed()
	if Input.is_action_just_pressed("Skill_two") and skill_two_ready:
		_on_skill_2_pressed()


func _on_skill_1_pressed() -> void:
	if not skill_one_ready:
		return
	var skill = scene_skillone.instantiate()
	add_child(skill)
	skill.global_position = player.global_position
	start_cooldown(1)


func _on_skill_2_pressed() -> void:
	if not skill_two_ready:
		return
	var skill = scene_skilltwo.instantiate()
	add_child(skill)
	skill.global_position = player.global_position
	skill.rotation = player.last_direction.angle()
	start_cooldown(2)


func start_cooldown(skill_index: int) -> void:
	if skill_index == 1:
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
