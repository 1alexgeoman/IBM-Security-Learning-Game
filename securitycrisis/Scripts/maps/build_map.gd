extends Node2D

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%StartButton.pressed.connect(start_game)
	%BackButton.pressed.connect(go_back)
	
func start_game() -> void:
	$Defences.save_defences()
	GameManager.change_scene(GameManager.WAVE_MAP_SCENE)

func go_back() -> void:
	$Defences.save_defences()
	GameManager.change_scene(GameManager.REAL_WORLD_MAP_SCENE)
