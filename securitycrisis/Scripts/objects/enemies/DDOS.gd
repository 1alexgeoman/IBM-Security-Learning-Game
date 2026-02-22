extends Enemy

func _init() -> void:
	damage2Turret = 4
	MAX_HEALTH = 25
	health = MAX_HEALTH

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	rotation += 0.025

	super._process(delta)
