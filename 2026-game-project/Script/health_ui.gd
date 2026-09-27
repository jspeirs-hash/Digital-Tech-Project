extends Control

@export var player: CharacterBody2D
@export var low_hp_percent: float = 0.3
@export var portrait: SubViewport
@export var healthbar: ProgressBar
@export var camera_portrait: Camera2D
@export var hp_outline: Control

var max_health: float = 0.0

func _ready() -> void:
	max_health = player.health
	portrait.world_2d = get_viewport().world_2d

func _process(delta: float) -> void:
	healthbar.max_value = max_health
	healthbar.value = player.health

	camera_portrait.global_position = player.global_position

	hp_outline.visible = player.health <= max_health * low_hp_percent
