extends Area2D

class_name Projectile

var v: Vector2
var start_pos: Vector2

var damage_type = DAMAGE_TYPES.ANTI_VIRUS
var damage: int = 20
var target_position: Vector2 = Vector2()
var source_turret_type: String = "GENERIC"

const CREATED_PROJ_SPEED: int = 500

func create(pos: Vector2, vel: Vector2, damage_mult: float, turret_type: String = "GENERIC") -> void:
	start_pos = pos
	v = vel
	rotation = v.angle()
	damage = damage * damage_mult
	source_turret_type = turret_type

func _ready() -> void:
	global_position = start_pos

	pass

func _process(delta: float) -> void:
	global_position += v * delta

func _on_area_entered(area:Area2D) -> void:
	if (area.is_in_group("Enemies")):
		hide()
		queue_free()
