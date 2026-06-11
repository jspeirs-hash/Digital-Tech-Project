extends CharacterBody2D

var speed: float = 300.0
var sprint: float = 500.0
var can_sprint: = false

func _process(delta: float) -> void:
	var direction: Vector2 = Vector2(0.0,0.0)
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")

	velocity = speed * direction.normalized()
	if Input.is_action_pressed("Sprint"):
		speed = sprint
	move_and_slide()

func sprints(delta: float) -> void:
	print()
