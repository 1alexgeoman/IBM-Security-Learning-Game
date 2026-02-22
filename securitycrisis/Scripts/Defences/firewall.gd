extends Defence

const MAX_ATTACK_COOLDOWN: float = 1.5
var attack_cooldown: float = 0

const ATTACK_DAMAGE: int = 10

const SLOW_DOWN_AMOUNT= 1.35

func get_colliding_enemies() -> Array:
	return get_overlapping_areas().filter(func(area): return area.is_in_group("Enemies"))

func damage_all_enemies() -> void:
	for enemy in get_colliding_enemies():
		var e: Enemy = enemy
		e.damage(DAMAGE_TYPES.BASIC, ATTACK_DAMAGE)

func slow_all_enemies() -> void:
	for enemy in get_colliding_enemies():
		var e: Enemy= enemy
		e.set_slowdown_effect(SLOW_DOWN_AMOUNT)

func process(delta: float) -> void:
	if is_disabled:
		return

	attack_cooldown += delta

	if attack_cooldown >= MAX_ATTACK_COOLDOWN:
		attack_cooldown = 0

		$AnimationPlayer.play("firewall_attack")

		damage_all_enemies()
		slow_all_enemies()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		var enemy: Enemy = area
		enemy.set_slowdown_effect(SLOW_DOWN_AMOUNT)

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		var enemy: Enemy = area
		enemy.remove_slowdown_effect()
