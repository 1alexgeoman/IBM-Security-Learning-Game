extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Button.pressed.connect(start_final_game)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_final_game() -> void:
	GameManager.change_scene(GameManager.REAL_WORLD_MAP_SCENE)
