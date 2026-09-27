extends Control

@export var player: CharacterBody2D
@export var low_hp_percent: float = 0.3

var max_health: float = 0.0

func _ready() -> void:
	max_health = player.health
	$Portrait/SubViewport.world_2d = get_viewport().world_2d

func _process(delta: float) -> void:
	$HealthBar.max_value = max_health
	$HealthBar.value = player.health

	$Portrait/SubViewport/PortraitCamera.global_position = player.global_position

	$"../LowHpOutline".visible = player.health <= max_health * low_hp_percent
