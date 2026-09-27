extends CharacterBody2D

# Constants
const INPUT_LEFT := "Left"
const INPUT_RIGHT := "Right"
const INPUT_UP := "Up"
const INPUT_DOWN := "Down"
const INPUT_DASH := "Dash"
const INPUT_SPRINT := "Sprint"
const INPUT_ATTACK := "Attack"
const COOLDOWN_TIMER_PATH := "Cooldown_dash"
const DURATION_TIMER_PATH := "Duration_dash"
const LEFT_NAME := "Left"
const RIGHT_NAME := "Right"
const UP_NAME := "Up"
const DOWN_NAME := "Down"
const IDLE_SIDE_ANIM := "idle-left_right"
const IDLE_BACK_ANIM := "idle-back"
const IDLE_FRONT_ANIM := "idle-front"
const WALK_SIDE_ANIM := "walk-left_right"

# Movement
@export var walk_speed: float = 260.0
@export var sprint_speed: float = 320.0
@export var dash_speed: float = 1000.0
@export var dash_duration: float = 3.0
@export var dash_cooldown: float = 3.0

var current_speed = walk_speed
var dash_direction: Vector2 = Vector2.ZERO
var can_dash = true
var is_dashing = false
var can_sprint: = false

# Spawner
@export var pivot: CharacterBody2D
@export var attack_scene: PackedScene
@export var spawn_attack: Marker2D
@export var sprite: AnimatedSprite2D


# Runs once when the node starts (nothing needed here).
func _ready() -> void:
	pass


# Every physics frame: read input, walk/dash/sprint, attack, then move.
func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	direction.x = Input.get_axis(INPUT_LEFT, INPUT_RIGHT)
	direction.y = Input.get_axis(INPUT_UP, INPUT_DOWN)
	direction = direction.normalized()

	velocity = walk_speed * direction.normalized()

	# Dashing mechanic
	if Input.is_action_just_pressed(INPUT_DASH) and can_dash and direction != Vector2.ZERO:
		is_dashing = true
		can_dash = false
		dash_direction = direction

		var cooldown_timer = get_node(COOLDOWN_TIMER_PATH)
		cooldown_timer.wait_time = dash_cooldown
		cooldown_timer.start()

		var duration_timer = get_node(DURATION_TIMER_PATH)
		duration_timer.wait_time = dash_duration
		duration_timer.start()

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

	if Input.is_action_just_pressed(INPUT_ATTACK):
		_attack()

	move_and_slide()

	_animation_sprite(direction)


# Picks an idle or walk animation name from the move direction (unfinished).
func _animation_sprite(move_dir: Vector2) -> void:
	# Create var for sprite.animation so it will be shorter
	var ani_target: String = sprite.animation
	if move_dir == Vector2.ZERO:
		if LEFT_NAME in sprite.animation or RIGHT_NAME in sprite.animation:
			ani_target = IDLE_SIDE_ANIM
		elif UP_NAME in sprite.animation:
			ani_target = IDLE_BACK_ANIM
		elif DOWN_NAME in sprite.animation:
			ani_target = IDLE_FRONT_ANIM
	else:
		# Using abs() to turn a negative number into a positive one
		if abs(move_dir.x) > abs(move_dir.y):
			if move_dir.x > 0:
				ani_target = WALK_SIDE_ANIM


# Dash time is over: stop dashing.
func _on_duration_dash_timeout() -> void:
	is_dashing = false


# Dash cooldown is over: allow dashing again.
func _on_cooldown_dash_timeout() -> void:
	can_dash = true


# Spawns the attack scene at the attack point.
func _attack() -> void:
	var attack = attack_scene.instantiate()
	attack.rotation = pivot.rotation
	attack.global_position = spawn_attack.global_position
	add_sibling(attack)
