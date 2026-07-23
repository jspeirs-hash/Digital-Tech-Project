extends CharacterBody2D

#movement
@export var walk_speed: float = 100.0
@export var sprint_speed: float = 320.0
@export var dash_speed: float = 1000.0
@export var dash_duration: float = 3.0
@export var dash_cooldown: float = 3.0

var current_speed = walk_speed
var dash_direction: Vector2 = Vector2.ZERO
var can_dash = true
var is_dashing = false
var can_sprint: = false
var idle = true
var last_direction: Vector2 = Vector2.RIGHT
var s_direction: Vector2 = Vector2.ZERO

#Spawner
@export var pivot: CharacterBody2D
@export var attack_scene: PackedScene
@export var spawn_attack: Marker2D
@export var sprite: AnimatedSprite2D

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	process_movement()
	move_and_slide()
	_attack()
	
	
func process_movement() -> void:
	var direction := Input.get_vector("Left", "Right", "Up", "Down")
	
	if direction != Vector2.ZERO:
		velocity = direction * walk_speed
		last_direction = direction
		s_direction = direction
	else:
		velocity = Vector2.ZERO
	
	process_animation(last_direction)
	
	#dashing mechanic
	if Input.is_action_just_pressed("Dash") and can_dash and s_direction != Vector2.ZERO:
		is_dashing = true
		can_dash = false
		dash_direction = s_direction
		
		var Cooldown_timer = get_node("Cooldown_dash")
		Cooldown_timer.wait_time = dash_cooldown
		Cooldown_timer.start()
		
		var Duration_timer = get_node("Duration_dash")
		Duration_timer.wait_time = dash_duration
		Duration_timer.start()
		
	if is_dashing:
		velocity = dash_direction * dash_speed
	else:
		#sprinting mechanic
		if Input.is_action_just_pressed("Sprint"):
			can_sprint = true
			if can_sprint:
				walk_speed = sprint_speed
		elif Input.is_action_just_released("Sprint"):
			can_sprint = false
			walk_speed = current_speed

func process_animation(direction) -> void:
	if velocity != Vector2.ZERO:
		change_animation("walk", direction)
	else:
		change_animation("idle", direction)

func change_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		sprite.flip_h = dir.x < 0
		sprite.play(prefix + "_right")
	elif dir.y < 0:
		sprite.play(prefix + "_up")
	elif dir.y > 0:
		sprite.play(prefix + "_down")
	
func _Duration_Dash_Timeout() -> void:
	is_dashing = false
	print("Duration")

func _Cooldown_Dash_Timeout() -> void:
	can_dash = true
	print("Cooldown")

func _attack() -> void:
	if Input.is_action_just_pressed("Attack"):
		sprite.play("attack_right")
	
