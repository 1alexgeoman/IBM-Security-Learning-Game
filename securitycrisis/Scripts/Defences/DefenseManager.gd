extends Node

# The count of turrets that can be deployed
var deploy_counts = {}

var fire_rate_boost_active: bool = false
var global_fire_rate_multiplier: float = 1.0
var global_damage_multiplier: float = 1.0
@onready var damage_boost_timer: Timer = Timer.new()

func _ready():
	damage_boost_timer.wait_time = 10.0
	damage_boost_timer.one_shot = true
	damage_boost_timer.timeout.connect(reset_damage_boost)
	add_child(damage_boost_timer)

func get_all_turrets() -> Array:
	return get_tree().get_nodes_in_group("Defences")

# Immediate application [Rate of Fire Boost] (permanent)
func upgrade_fire_rate():
	global_fire_rate_multiplier = global_fire_rate_multiplier * 0.75
	for turret in get_all_turrets():
		turret.apply_fire_rate_upgrade()

# Immediate application [Damage Boost] (10s)
func upgrade_damage_boost():
	if damage_boost_timer.time_left <= 0:
		global_damage_multiplier = 1.5
		damage_boost_timer.start(10.0)

	else:
		var remaining_time = damage_boost_timer.time_left + 10.0
		damage_boost_timer.start(remaining_time)  # restart the timer of new time left


	for turret in get_all_turrets():
		turret.apply_damage_boost()

func reset_damage_boost():
	global_damage_multiplier = 1.0
	for turret in get_all_turrets():
		turret.reset_damage_boost()

func get_deploy_count(defense_type: String) -> int:
	if not deploy_counts.has(defense_type):
		deploy_counts[defense_type] = 0
	
	return deploy_counts[defense_type]

func modify_deploy_count(defense_type: String, count: int):
	if not deploy_counts.has(defense_type):
		deploy_counts[defense_type] = 0
	
	deploy_counts[defense_type] += count
