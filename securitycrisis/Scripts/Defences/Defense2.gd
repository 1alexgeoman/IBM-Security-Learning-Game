extends Turret

func fire() -> void:
	add_child(create_projectile($Turret/Muzzle0))
	add_child(create_projectile($Turret/Muzzle1))
