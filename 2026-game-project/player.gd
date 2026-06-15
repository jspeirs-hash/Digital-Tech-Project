extends CharacterBody2D

var speed: float = 300.0
var walk_speed: float = 300.0
var sprint_speed: float = 500.0
var dash_distance: float = 1000.0
var can_sprint: = false
var can_dash = false

func _process(delta: float) -> void:
	var direction: Vector2 = Vector2(0.0,0.0)
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")

	
	#sprinting mechanic
	if Input.is_action_just_pressed("Sprint"):
		can_sprint = true
		if can_sprint:
			walk_speed = sprint_speed
	elif Input.is_action_just_released("Sprint"):
		can_sprint = false
		walk_speed = speed
	
	#dashing mechanic
	if Input.is_action_just_pressed("Dash"):
		can_dash = true
		if can_dash:
			velocity = dash_distance * direction
			print("dash")
	else:
		can_dash = false
		
	velocity = walk_speed * direction.normalized()
	
	move_and_slide()
