extends Area2D

class_name ProjectileTargeting

const SPEED: int = 10

var target: Node2D
var start_pos: Vector2

func create(start_pos: Vector2, target_: Node2D) -> void:
	target = target_
	start_pos = start_pos

func _ready() -> void:
	global_position = start_pos

func _process(delta: float) -> void:
	var v_diff: Vector2 = target.global_position - global_position
	global_position += SPEED * delta * v_diff
