extends GutTest

var real_world_scene: Node2D
var real_world_double: Node2D
var animation_player_double: AnimationPlayer
var original_script: Script

func before_all() -> void:
	var scene_packed = load("res://Scenes/Maps/real_world_map.tscn")
	real_world_scene = scene_packed.instantiate()

func before_each() -> void:
	original_script = load("res://Scripts/maps/real_world_map.gd")
	# Create a double instance
	real_world_double = double(original_script).new()
	add_child(real_world_double)
	
	animation_player_double = double(AnimationPlayer).new()
	real_world_double.animation = animation_player_double
	
	real_world_double.main_components = double(Node2D).new()
	
	# Monitoring method
	stub(real_world_double, "_opening_scene_start").to_do_nothing()
	stub(real_world_double, "_opening_scene_end").to_do_nothing()
	stub(animation_player_double, "play").to_do_nothing()

func after_each() -> void:
	if is_instance_valid(real_world_double):
		remove_child(real_world_double)
		real_world_double.queue_free()

func after_all() -> void:
	if is_instance_valid(real_world_scene):
		real_world_scene.queue_free()

func test_opening_scene_start_called() -> void:
	real_world_double._opening_scene_start()
	
	assert_called(real_world_double, "_opening_scene_start")

func test_opening_scene_end_called() -> void:
	real_world_double._opening_scene_end()
	
	assert_called(real_world_double, "_opening_scene_end")
