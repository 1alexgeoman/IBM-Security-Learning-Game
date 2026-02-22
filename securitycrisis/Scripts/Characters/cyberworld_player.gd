extends CharacterBody2D
# requires health
# added code to timeout and reset position
# animation for attacking possibly

class_name CyberPlayer

signal player_health_changed(new_health)
signal player_died

var facing_left: bool= false

const SPEED = 300.0
@export var animated_sprite: AnimatedSprite2D

const MAX_HEALTH: int = 100
var health: int = MAX_HEALTH

func respawned() -> void:
	health= MAX_HEALTH
	player_health_changed.emit(health)

var is_dead: bool = false

func damage(amount: int) -> void:
	if is_dead:
		return
	
	health -= amount
	
	if health <= 0:
		health = 0
		died()
	
	player_health_changed.emit(health)

func died() -> void:
	is_dead = true
	player_died.emit()
	
func reset() -> void:
	health = 100
	is_dead = false
	player_health_changed.emit(health)

func is_alive() -> bool:
	return health > 0

func _physics_process(_delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()

	if mouse_pos.x < global_position.x and not facing_left:
		scale.x = -abs(scale.x)
		facing_left = true
	elif mouse_pos.x >= global_position.x and facing_left:
		scale.x = -abs(scale.x)
		facing_left = false

	#when map is hidden player can't move
	if not get_parent().visible:
		return

	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
		
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
		
	 # Handle animations
	if direction.x != 0:
		animated_sprite.play("run")  # Play side walk animation
	else:
		animated_sprite.play("idle")  # Play idle animation when not moving
	
	move_and_slide()
