extends Area2D

class_name Defence

@export var targetable_defence: bool = true

signal defence_damaged(amount)
signal defence_destroyed
var has_been_sped_up = false

var disable_timer = 0.0
var is_disabled = false  

# 1-2, 2 means things take twice as long
var slow_timer: float= 0
var slow_effect: float= 1

const UPDATE_DELTA_MAX: float = 0.05;
var update_delta: float = 0;

func update() -> void:
	pass

func process(delta: float) -> void:
	pass
	
func get_enemy_attack_shape() -> CollisionShape2D:
	return get_node("CollisionShape2D")

func _process(delta: float) -> void:
	if is_disabled:
		disable_timer -= delta
		if disable_timer <= 0:
			restore_defence()
		return

	if slow_effect != 1:
		slow_timer -= delta
		if slow_timer <= 0:
			slow_effect= 1

	# effective delta for processing movement
	process(delta / slow_effect)

	update_delta += delta;
	
	if (update_delta >= UPDATE_DELTA_MAX * slow_effect):
		update_delta = 0
		update()

func damage(health_loss: int) -> void:
	update_health(health_loss)

	defence_damaged.emit(health_loss)

	if ($healthBar.value <= 0):
		defence_destroyed.emit()
		hide()
		queue_free()
		
func update_health(change: int) -> void:
	$healthBar.value -= change
	
func disable_defence(duration: float):
	if is_disabled:
		return

	is_disabled = true
	disable_timer = duration
	modulate = Color(0.5, 0.5, 0.5)

func slow_defence(duration: float, factor: float):
	if slow_effect != 1:
		return

	# if there are different amounts of slow this will need to change
	slow_effect= max(slow_effect, factor)
	slow_timer= duration
	
func restore_defence():
	is_disabled = false
	modulate = Color(1, 1, 1)
	has_been_sped_up = false
