extends CharacterBody2D

# Constants
const INPUT_LEFT := "Left"
const INPUT_RIGHT := "Right"
const INPUT_UP := "Up"
const INPUT_DOWN := "Down"
const INPUT_DASH := "Dash"
const INPUT_SPRINT := "Sprint"
const INPUT_ATTACK := "Attack"
const ENEMY_GROUP := "enemy"
const WALK_ANIM := "walk"
const IDLE_ANIM := "idle"
const ATTACK_ANIM := "attack"
const RIGHT_SUFFIX := "_right"
const UP_SUFFIX := "_up"
const DOWN_SUFFIX := "_down"
const DEATH_SCENE := "res://Scene/death.tscn"
const KNOCKBACK_TIME := 0.2
const SWORD_DISTANCE := 16.0
const DEFAULT_DAMAGE := 1.0
const NO_MAP_LIMIT := 100000.0

# Movement
@export var walk_speed: float = 100.0
@export var sprint_speed: float = 150.0
@export var dash_speed: float = 450.0
@export var dash_duration: float = 3.0
@export var dash_cooldown: float = 3.0
@export var health: float = 10.0
@export var camera: Camera2D

var current_speed = walk_speed
var dash_direction: Vector2 = Vector2.ZERO
var can_dash = true
var is_dashing = false
var can_sprint: = false
var idle = true
var last_direction: Vector2 = Vector2.RIGHT
var s_direction: Vector2 = Vector2.ZERO
var vec = Vector2.ZERO
var animation_movement = true
var animation = false
var enemy = CharacterBody2D
var max_health: float = 0.0

# Damage bonus from killing bosses
@export var damage_per_boss: float = 0.5
@export var skill_damage_per_boss: float = 1.0
var damage_bonus: float = 0.0
var skill_damage_bonus: float = 0.0

# Knockback
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

# Map edges
@export var edge_margin: float = 8.0
var map_top_left: Vector2 = Vector2(-NO_MAP_LIMIT, -NO_MAP_LIMIT)
var map_bottom_right: Vector2 = Vector2(NO_MAP_LIMIT, NO_MAP_LIMIT)

# Spawner
@export var pivot: CharacterBody2D
@export var attack_scene: PackedScene
@export var spawn_attack: Marker2D
@export var sprite: AnimatedSprite2D
@export var cooldown_dash: Timer
@export var duration_dash: Timer
@export var delete_attack_timer: Timer
@export var dirt_trail: CPUParticles2D
@export var hit_sound: AudioStreamPlayer
@export var swing_sound: AudioStreamPlayer

# Attack
@export var attack_timer: Timer
@export var attack_cooldown_timer: Timer
var on_attack = true
var attacking = false
var attack_cooldown = true


# Remembers the starting health as the most the player can heal back up to.
func _ready() -> void:
	max_health = health


# Every physics frame: knockback or normal movement, move, stay inside the map, then attack.
func _physics_process(delta: float) -> void:
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
	else:
		process_movement()
	move_and_slide()
	global_position = global_position.clamp(map_top_left, map_bottom_right)
	_attack()
	attack_hitbox()


# Pushes the player in a direction for KNOCKBACK_TIME seconds.
func apply_knockback(dir: Vector2, force: float) -> void:
	knockback = dir.normalized() * force
	knockback_timer = KNOCKBACK_TIME


# Called when a boss dies: the sword and skills do more damage from now on.
func boss_defeated() -> void:
	damage_bonus += damage_per_boss
	skill_damage_bonus += skill_damage_per_boss


# Gives back health, but never more than max_health.
func heal(amount: float) -> void:
	health = min(health + amount, max_health)


# Saves the map edges (moved in by edge_margin) and stops the camera going past them.
func set_map_limits(top_left: Vector2, bottom_right: Vector2) -> void:
	var margin = Vector2(edge_margin, edge_margin)
	map_top_left = top_left + margin
	map_bottom_right = bottom_right - margin

	camera.limit_left = int(top_left.x)
	camera.limit_top = int(top_left.y)
	camera.limit_right = int(bottom_right.x)
	camera.limit_bottom = int(bottom_right.y)


# Reads the movement keys and handles walking, dashing, sprinting and the dirt trail.
func process_movement() -> void:
	var direction := Input.get_vector(INPUT_LEFT, INPUT_RIGHT, INPUT_UP, INPUT_DOWN)

	if direction != vec:
		velocity = direction * walk_speed
		last_direction = direction
		s_direction = direction
	else:
		velocity = vec

	process_animation(last_direction)

	# Dashing mechanic
	if Input.is_action_just_pressed(INPUT_DASH) and can_dash and s_direction != vec:
		is_dashing = true
		can_dash = false
		dash_direction = s_direction

		cooldown_dash.wait_time = dash_cooldown
		cooldown_dash.start()

		duration_dash.wait_time = dash_duration
		duration_dash.start()

	if is_dashing:
		velocity = dash_direction * dash_speed
	else:
		# Sprinting mechanic
		if Input.is_action_just_pressed(INPUT_SPRINT):
			can_sprint = true
			if can_sprint:
				walk_speed = sprint_speed
		elif Input.is_action_just_released(INPUT_SPRINT):
			can_sprint = false
			walk_speed = current_speed

	dirt_trail.emitting = velocity != vec


# Plays the walk animation while moving, idle when standing still.
func process_animation(direction) -> void:
	if not animation_movement:
		return

	if velocity != vec:
		change_animation(WALK_ANIM, direction)
	else:
		if animation_movement:
			change_animation(IDLE_ANIM, direction)


# Plays the right/up/down version of an animation, flipping the sprite for left.
func change_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		sprite.flip_h = dir.x < 0
		sprite.play(prefix + RIGHT_SUFFIX)
	elif dir.y < 0:
		sprite.play(prefix + UP_SUFFIX)
	elif dir.y > 0:
		sprite.play(prefix + DOWN_SUFFIX)


# Dash time is over: stop dashing.
func _on_duration_dash_timeout() -> void:
	is_dashing = false


# Dash cooldown is over: allow dashing again.
func _on_cooldown_dash_timeout() -> void:
	can_dash = true


# When the attack button is pressed and ready: start the timers, animation and swing sound.
func _attack() -> void:
	if Input.is_action_just_pressed(INPUT_ATTACK) and attack_cooldown:
		animation_movement = false
		attack_timer.start()
		attack_cooldown = false
		attack_cooldown_timer.start()
		play_attack_animation()
		swing_sound.play()
		on_attack = false
		attacking = true


# Attack animation finished: let walk/idle animations play again.
func _attack_animation_cooldown_end() -> void:
	animation_movement = true
	on_attack = true


# Plays the attack animation facing the last direction moved.
func play_attack_animation() -> void:
	if abs(last_direction.x) >= abs(last_direction.y):
		sprite.flip_h = last_direction.x < 0
		sprite.play(ATTACK_ANIM + RIGHT_SUFFIX)
	elif last_direction.y < 0:
		sprite.play(ATTACK_ANIM + UP_SUFFIX)
	else:
		sprite.play(ATTACK_ANIM + DOWN_SUFFIX)


# Spawns the sword hitbox in front of the player, then removes it after a short time.
func attack_hitbox() -> void:
	if attacking:
		attacking = false
		var attack = attack_scene.instantiate()
		attack.damage += damage_bonus
		add_child(attack)
		attack.global_position = spawn_attack.global_position + last_direction * SWORD_DISTANCE
		attack.rotation = last_direction.angle()
		delete_attack_timer.start()
		await delete_attack_timer.timeout
		if is_instance_valid(attack):
			attack.queue_free()


# Attack cooldown is over: allow attacking again.
func _on_attack_cooldown_timeout() -> void:
	attack_cooldown = true


# Takes damage when an enemy touches the player.
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group(ENEMY_GROUP):
		damage_player()


# Loses health (1 unless told otherwise) and plays the hit sound; goes to the death screen at 0.
func damage_player(amount: float = DEFAULT_DAMAGE) -> void:
	health -= amount
	print(health)
	hit_sound.play()
	if health <= 0:
		get_tree().change_scene_to_file(DEATH_SCENE)


# Not used (kept because a timer signal is connected to it).
func _on_delete_attack_timeout() -> void:
	pass
