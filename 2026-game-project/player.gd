extends CharacterBody2D

#movement
@export var walk_speed: float = 100.0
@export var sprint_speed: float = 320.0
@export var dash_speed: float = 1000.0
@export var dash_duration: float = 3.0
@export var dash_cooldown: float = 3.0
@export var health: float = 5.0

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

#Spawner
@export var pivot: CharacterBody2D
@export var attack_scene: PackedScene
@export var spawn_attack: Marker2D
@export var sprite: AnimatedSprite2D
@export var cooldown_dash: Timer
@export var duration_dash: Timer
@export var delete_attack_timer: Timer

#attack
@export var attack_timer: Timer
@export var attack_cooldown_timer: Timer
var on_attack = true
var attacking = false
var attack_cooldown = true

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	process_movement()
	move_and_slide()
	_attack()
	attack_hitbox()
	
func process_movement() -> void:
	var direction := Input.get_vector("Left", "Right", "Up", "Down")
	
	if direction != vec and on_attack:
		velocity = direction * walk_speed
		last_direction = direction
		s_direction = direction
	else:
		velocity = vec
	
	process_animation(last_direction)
	
	#dashing mechanic
	if Input.is_action_just_pressed("Dash") and can_dash and s_direction != vec:
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
	if velocity != vec:
		change_animation("walk", direction)
	else:
		if animation_movement:
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

func _Cooldown_Dash_Timeout() -> void:
	can_dash = true

func _attack() -> void:
	if Input.is_action_just_pressed("Attack"):
		animation_movement = false
		attack_timer.start()
		if attack_cooldown:
			sprite.play("attack_right")
			on_attack = false
			attacking = true

func _attack_animation_cooldown_end() -> void:
	animation_movement = true
	on_attack = true
	
func attack_hitbox() -> void:
	if attacking:
		attacking = false
		if attack_cooldown:
			var attack = attack_scene.instantiate()
			add_child(attack)
			attack_cooldown = false
			attack_cooldown_timer.start()
			delete_attack_timer.start()
			await delete_attack_timer.timeout
			attack.tree_exited

func _on_attack_cooldown_timeout() -> void:
	attack_cooldown = true


func _on_hitbox_body_entered(body: Node2D) -> void:
	var enemy = get_tree().get_first_node_in_group("enemy")
	body = enemy
	if body.is_in_group("enemy"):
		damage_player()
		if health == 0:
			queue_free()

func damage_player() -> void:
	health -= 1
	print(health)


func _on_delete_attack_timeout() -> void:
	pass
