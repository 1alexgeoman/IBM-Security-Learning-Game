extends Area2D
class_name Weapon

# need further additions
# ensure weapon attack interval is "fair"

var damage_type = DAMAGE_TYPES.ANTI_VIRUS
var damage: int = 10

@export var HIT_INTERVAL_MAX: float = 0.1
var hit_interval: float= 0

const SWING_SPEED: float = 10
var swing_idx: float = 0
var swing_dir: int = 1
const MAX_SWING_IDX: float = PI / 4
const MIN_SWING_IDX: float = -PI / 3

var attacking: bool = false

var enemy_set: Dictionary= {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("area_exited", Callable(self, "_on_area_exited"))
				
func _unhandled_input(_event: InputEvent) -> void:
	if not Input.is_action_pressed("attack"):
		return

	if attacking:
		return

	if hit_interval > 0:
		return

	start_attacking()
			
func start_attacking():
	attacking= true
	enemy_set.clear()

func end_attacking():
	attacking= false
	hit_interval= HIT_INTERVAL_MAX
		
func swing(delta: float):
	if swing_idx == MAX_SWING_IDX:
		swing_dir *= -1

	if swing_idx == MIN_SWING_IDX:
		swing_dir= 1
		end_attacking()

	swing_idx += delta * SWING_SPEED * swing_dir

	swing_idx= clamp(swing_idx, MIN_SWING_IDX, MAX_SWING_IDX)

	rotation= swing_idx - PI / 4

func attack():
	for enemy in get_overlapping_areas():
		if not enemy.is_in_group("Enemies"):
			return

		if enemy_set.has(enemy):
			continue

		var e: Enemy= enemy
		enemy_set[e]= 1
		e.damage(damage_type, damage)

func _process(delta: float) -> void:
	hit_interval -= delta

	if attacking:
		swing(delta)
		attack()
