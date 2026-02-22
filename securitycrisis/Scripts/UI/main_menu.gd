extends Control

@onready var target_camera_position: Vector2= $CameraPath/CameraFollow.position

const CAMERA_SPEED: float= 40

@onready var real_world_map_scene: PackedScene = preload("res://Scenes/Maps/real_world_map.tscn")

## starts game
func _on_game_start_pressed() -> void:
	GameManager.game_start = true
	GameManager.change_to_preloaded_scene(real_world_map_scene)
	
func new_camera_target() -> void:
	$CameraPath/CameraFollow.progress_ratio += randf_range(0.25, 0.5)
	target_camera_position= $CameraPath/CameraFollow.position

func _process(delta: float) -> void:
	if ($Camera2D.position.distance_squared_to(target_camera_position) <= 0.01):
		new_camera_target()

	$Camera2D.position= $Camera2D.position.move_toward(target_camera_position, delta * CAMERA_SPEED)
