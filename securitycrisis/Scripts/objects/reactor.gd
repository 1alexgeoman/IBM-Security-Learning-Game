extends Node2D

class_name Reactor

const MAX_HEALTH: int = 1000
var health: int = MAX_HEALTH

signal reactor_destroyed
signal reactor_health_change(new_health)

func update_health_bar():
	$HealthBar.value = ((health as float / MAX_HEALTH) * 100) 

func _ready() -> void:
	update_health_bar()

func reset_health() -> void:
	health= MAX_HEALTH

func damage(amount: int) -> void:
	health -= amount

	if (health <= 0):
		reactor_destroyed.emit()
	
	reactor_health_change.emit(max(health, 0))
	update_health_bar()
