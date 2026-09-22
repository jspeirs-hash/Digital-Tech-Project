extends Node2D

@onready var terrain_layer: TileMapLayer = $Map/Main
@export var skillone: Button
@export var skilltwo: Button
@export var scene_skillone: PackedScene

func _ready() -> void:
	var dirt_cells: Array[Vector2i] = []
	for cell in terrain_layer.get_used_cells():
		var tile_data := terrain_layer.get_cell_tile_data(cell)
		if tile_data != null and tile_data.terrain_set == 1:
			dirt_cells.append(cell)
	if not dirt_cells.is_empty():
		terrain_layer.set_cells_terrain_connect(dirt_cells, 1, 0)

func _process(delta: float) -> void:
	use_skill()

func use_skill() -> void:
	if Input.is_action_just_pressed("Skill_one"):
		_on_skill_1_pressed()


func _on_skill_1_pressed() -> void:
	var skill = scene_skillone.instantiate()
	add_child(skill)
	print(skill)
	skill.global_position = $Charactor/Player.global_position
