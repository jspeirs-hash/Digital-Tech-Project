extends CharacterBody2D

#movement
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

#Spawner
@export var pivot: CharacterBody2D
@export var attack_scene: PackedScene
@export var spawn_attack: Marker2D
@export var sprite: AnimatedSprite2D

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	direction.x = Input.get_axis("Left", "Right")
	direction.y = Input.get_axis("Up", "Down")
	direction = direction.normalized()
	
	velocity = walk_speed * direction.normalized()
	
	#dashing mechanic
	if Input.is_action_just_pressed("Dash") and can_dash and direction != Vector2.ZERO:
		is_dashing = true
		can_dash = false
		dash_direction = direction
		
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
		
	if Input.is_action_just_pressed("Attack"):
		_attack()
	
	move_and_slide()
	
	_animation_sprite(direction)

func _animation_sprite(move_dir: Vector2) -> void:
	#create var for sprite.animation so it will be shorter
	var ani_target: String = sprite.animation
	if move_dir == Vector2.ZERO:
		if "Left" in sprite.animation or "Right" in sprite.animation:
			ani_target = "idle-left_right"
		elif "Up" in sprite.animation:
			ani_target = "idle-back"
		elif "Down" in sprite.animation:
			ani_target = "idle-front"
	else:
		#using abs() to turn the negative to positive valuable
		if abs(move_dir.x) > abs(move_dir.y):
			if move_dir.x > 0:
				ani_target = "walk-left_right"
func _Duration_Dash_Timeout() -> void:
	is_dashing = false
	print("Duration")

func _Cooldown_Dash_Timeout() -> void:
	can_dash = true
	print("Cooldown")

func _attack() -> void:
	var attack = attack_scene.instantiate()
	attack.rotation = pivot.rotation
	attack.global_position = spawn_attack.global_position
	add_sibling(attack)
