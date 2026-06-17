extends CharacterBody2D

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

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	
	velocity = walk_speed * direction.normalized()
	
	#dashing mechanic
	if Input.is_action_just_pressed("Dash") and can_dash and direction != Vector2.ZERO:
		
		is_dashing = true
		can_dash = false
		dash_direction = direction.normalized()
		
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
	move_and_slide()

func _Duration_Dash_Timeout() -> void:
	is_dashing = false
	print("Duration")

func _Cooldown_Dash_Timeout() -> void:
	can_dash = true
	print("Cooldown")
