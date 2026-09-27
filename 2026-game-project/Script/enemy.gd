extends CharacterBody2D

@export var speed: float = 70.0
@export var health: float = 2.0
@export var attack_range: float = 20.0
@export var attack_damage: float = 1.0
@export var attack_time: float = 1.0

var player = null
var attack_timer: float = 0.0

#knockback
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

#hit flash
var hit_flash_timer: float = 0.0

@export var enemy: CharacterBody2D
@export var sprite: AnimatedSprite2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if hit_flash_timer > 0.0:
		hit_flash_timer -= delta
		if hit_flash_timer <= 0.0:
			sprite.modulate = Color(1, 1, 1)

	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
		move_and_slide()
	else:
		_chase_and_attack(delta)

func apply_knockback(dir: Vector2, force: float) -> void:
	knockback = dir.normalized() * force
	knockback_timer = 0.2

func _chase_and_attack(delta: float) -> void:
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var distance = position.distance_to(player.position)

	if distance <= attack_range:
		velocity = Vector2.ZERO
		sprite.play("idle_right")
		attack_timer += delta
		if attack_timer >= attack_time:
			attack_timer = 0.0
			attack_player()
	else:
		velocity = position.direction_to(player.position) * speed
		sprite.play("walk_right")
		if (player.position.x - position.x) < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		move_and_slide()

func attack_player() -> void:
	if player.has_method("damage_player"):
		player.damage_player()

func _on_get_hit_body_entered(body: Node2D) -> void:
	if body.is_in_group("attack"):
		take_damage()

func take_damage(amount: float = 1.0) -> void:
	health -= amount
	print(health)
	sprite.modulate = Color(1, 0, 0)
	hit_flash_timer = 0.15
	if health <= 0:
		queue_free()
