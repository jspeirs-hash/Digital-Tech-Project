extends CharacterBody2D

#movement
@export var walk_speed: float = 100.0
@export var sprint_speed: float = 120.0
@export var dash_speed: float = 450.0
@export var dash_duration: float = 3.0
@export var dash_cooldown: float = 3.0
@export var health: float = 5.0
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

#knockback
var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

#map edges
@export var edge_margin: float = 8.0
var map_top_left: Vector2 = Vector2(-100000, -100000)
var map_bottom_right: Vector2 = Vector2(100000, 100000)

#Spawner
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

#attack
@export var attack_timer: Timer
@export var attack_cooldown_timer: Timer
var on_attack = true
var attacking = false
var attack_cooldown = true

# Runs once when the player starts (nothing needed here).
func _ready() -> void:
	pass

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
	global_position.x = clamp(global_position.x, map_top_left.x + edge_margin, map_bottom_right.x - edge_margin)
	global_position.y = clamp(global_position.y, map_top_left.y + edge_margin, map_bottom_right.y - edge_margin)
	_attack()
	attack_hitbox()

# Pushes the player in a direction for 0.2 seconds.
func apply_knockback(dir: Vector2, force: float) -> void:
	knockback = dir.normalized() * force
	knockback_timer = 0.2

# Saves the map edges and stops the camera going past them.
func set_map_limits(top_left: Vector2, bottom_right: Vector2) -> void:
	map_top_left = top_left
	map_bottom_right = bottom_right

	camera.limit_left = int(top_left.x)
	camera.limit_top = int(top_left.y)
	camera.limit_right = int(bottom_right.x)
	camera.limit_bottom = int(bottom_right.y)

# Reads the movement keys and handles walking, dashing, sprinting and the dirt trail.
func process_movement() -> void:
	var direction := Input.get_vector("Left", "Right", "Up", "Down")

	if direction != vec:
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

	dirt_trail.emitting = velocity != vec

# Plays the walk animation while moving, idle when standing still.
func process_animation(direction) -> void:
	if not animation_movement:
		return

	if velocity != vec:
		change_animation("walk", direction)
	else:
		if animation_movement:
			change_animation("idle", direction)

# Plays the right/up/down version of an animation, flipping the sprite for left.
func change_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		sprite.flip_h = dir.x < 0
		sprite.play(prefix + "_right")
	elif dir.y < 0:
		sprite.play(prefix + "_up")
	elif dir.y > 0:
		sprite.play(prefix + "_down")

# Dash time is over: stop dashing.
func _Duration_Dash_Timeout() -> void:
	is_dashing = false

# Dash cooldown is over: allow dashing again.
func _Cooldown_Dash_Timeout() -> void:
	can_dash = true

# When the attack button is pressed and ready: start the timers, animation and swing sound.
func _attack() -> void:
	if Input.is_action_just_pressed("Attack") and attack_cooldown:
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
		sprite.play("attack_right")
	elif last_direction.y < 0:
		sprite.play("attack_up")
	else:
		sprite.play("attack_down")

# Spawns the sword hitbox in front of the player, then removes it after a short time.
func attack_hitbox() -> void:
	if attacking:
		attacking = false
		var attack = attack_scene.instantiate()
		add_child(attack)
		attack.global_position = spawn_attack.global_position + last_direction * 16.0
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
	if body.is_in_group("enemy"):
		damage_player()


# Loses 1 health and plays the hit sound; goes to the death screen at 0.
func damage_player() -> void:
	health -= 1
	print(health)
	hit_sound.play()
	if health <= 0:
		get_tree().change_scene_to_file("res://Scene/death.tscn")


# Not used (kept because a timer signal is connected to it).
func _on_delete_attack_timeout() -> void:
	pass
