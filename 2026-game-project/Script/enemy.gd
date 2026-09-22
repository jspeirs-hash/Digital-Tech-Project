extends CharacterBody2D

@export var speed: float = 70.0
@export var health: float = 2.0

var player = null
var chasing = false 
var last_direction: Vector2 = Vector2.RIGHT

@export var enemy: CharacterBody2D
@export var sprite: AnimatedSprite2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	_chasing()

func _chasing() -> void:
	player = get_tree().get_first_node_in_group("player")
	velocity = Vector2.ZERO
	if chasing and player != null:
		velocity = position.direction_to(player.position) * speed
		sprite.play("walk_right")
		if (player.position.x - position.x) < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		move_and_slide()
		
	else:
		sprite.play("idle_right")

func change_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		sprite.flip_h = dir.x < 0
		sprite.play(prefix + "_right")
	elif dir.y < 0:
		sprite.play(prefix + "_up")
	elif dir.y > 0:
		sprite.play(prefix + "_down")

func player_enter(body: Node2D) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if body == player:
		chasing = true

func player_out(body: Node2D) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		chasing = false
		

func _body_enter(body: Node2D) -> void:
	pass

func _on_get_hit_body_entered(body: Node2D) -> void:
	if body.is_in_group("attack"):
		take_damage()


func take_damage(amount: float = 1.0) -> void:
	health -= amount
	print(health)
	if health <= 0:
		queue_free()
