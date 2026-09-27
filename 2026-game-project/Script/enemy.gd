extends CharacterBody2D

# Constants
const PLAYER_GROUP := "player"
const ATTACK_GROUP := "attack"
const IDLE_ANIM := "idle_right"
const WALK_ANIM := "walk_right"
const KNOCKBACK_TIME := 0.2
const HIT_FLASH_TIME := 0.15
const HIT_FLASH_COLOR := Color(1, 0, 0)
const NORMAL_COLOR := Color(1, 1, 1)
const DEFAULT_DAMAGE := 1.0

@export var speed: float = 80.0
@export var health: float = 3.0
@export var attack_range: float = 20.0
@export var attack_damage: float = 1.0
@export var attack_time: float = 1.0

var player = null
var attack_timer: float = 0.0
var is_boss: bool = false

# Knockback
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

# Hit flash
var hit_flash_timer: float = 0.0

@export var enemy: CharacterBody2D
@export var sprite: AnimatedSprite2D
@export var hit_sound: AudioStreamPlayer
@export var death_sound: AudioStreamPlayer
@export var health_bar: ProgressBar


# Finds the player and fills the health bar when the slime spawns.
func _ready() -> void:
	player = get_tree().get_first_node_in_group(PLAYER_GROUP)
	health_bar.max_value = health
	health_bar.value = health


# Every physics frame: fade the red hit flash, then either get knocked back or chase.
func _physics_process(delta: float) -> void:
	if hit_flash_timer > 0.0:
		hit_flash_timer -= delta
		if hit_flash_timer <= 0.0:
			sprite.modulate = NORMAL_COLOR

	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
		move_and_slide()
	else:
		_chase_and_attack(delta)


# Pushes the slime in a direction for KNOCKBACK_TIME seconds.
func apply_knockback(dir: Vector2, force: float) -> void:
	knockback = dir.normalized() * force
	knockback_timer = KNOCKBACK_TIME


# Walks toward the player, or stops and attacks every attack_time seconds when close.
func _chase_and_attack(delta: float) -> void:
	player = get_tree().get_first_node_in_group(PLAYER_GROUP)
	if player == null:
		return

	var distance = position.distance_to(player.position)

	if distance <= attack_range:
		velocity = Vector2.ZERO
		sprite.play(IDLE_ANIM)
		attack_timer += delta
		if attack_timer >= attack_time:
			attack_timer = 0.0
			attack_player()
	else:
		velocity = position.direction_to(player.position) * speed
		sprite.play(WALK_ANIM)
		if (player.position.x - position.x) < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		move_and_slide()


# Hurts the player.
func attack_player() -> void:
	player.damage_player(attack_damage)


# Takes damage when something in the attack group touches the slime.
func _on_get_hit_body_entered(body: Node2D) -> void:
	if body.is_in_group(ATTACK_GROUP):
		take_damage()


# Loses health, flashes red and plays a sound; dies when health reaches 0.
func take_damage(amount: float = DEFAULT_DAMAGE) -> void:
	health -= amount
	print(health)
	health_bar.value = health
	sprite.modulate = HIT_FLASH_COLOR
	hit_flash_timer = HIT_FLASH_TIME
	if health <= 0:
		if is_boss:
			player.boss_defeated()
		death_sound.reparent(get_tree().current_scene)
		death_sound.play()
		death_sound.finished.connect(death_sound.queue_free)
		queue_free()
	else:
		hit_sound.play()
