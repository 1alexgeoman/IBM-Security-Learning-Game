extends Enemy

class_name PhishingEnemy

func _ready():
	effect_factor = 2
	effect_duration = 5.0

	damage2Turret= 5

func process_actions(delta: float) -> void:
	attack_cooldown += delta

	var attack_area = get_attack_area_(true, true, false)
	var at_attack_point = move_toward_nearest_point_on(attack_area, delta)

	if (at_attack_point):
		attempt_attack(attack_area)

func attempt_attack(target) -> void:
	if attack_cooldown < ATTACK_COOLDOWN_MAX:
		return
	
	attack_cooldown = 0

	if target is Defence:
		var d: Defence= target
		d.slow_defence(effect_duration, effect_factor)

	target.damage(damage2Turret)
