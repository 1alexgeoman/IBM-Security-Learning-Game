extends GutTest

var real_world_scene: Node2D
var player: CharacterBody2D
var captain: Area2D
var shop_ui: Control
var original_captain: Area2D
var captain_sprite: Sprite2D

func before_all() -> void:
	# Load the real_world scene
	var scene_packed = load("res://Scenes/Maps/real_world_map.tscn")
	real_world_scene = scene_packed.instantiate()
	add_child(real_world_scene)

func before_each() -> void:
	player = real_world_scene.get_node("MainComponents/Player")
	original_captain = real_world_scene.get_node("%CaptainNPC") 
	
	# Double the part of creating a captain
	var captain_script = load("res://Scripts/Characters/captain_npc.gd")
	captain = partial_double(captain_script).new()
	

	captain.player_inside = true
	
	real_world_scene.remove_child(original_captain)
	real_world_scene.add_child(captain)
	
	# Monitor the trigger_event call
	stub(captain, "trigger_event").to_do_nothing()

func after_each() -> void:
	if is_instance_valid(captain):
		real_world_scene.remove_child(captain)
		captain.queue_free()
	
	if is_instance_valid(original_captain) and not original_captain.is_inside_tree():
		real_world_scene.add_child(original_captain)

func after_all() -> void:
	if is_instance_valid(real_world_scene):
		if is_instance_valid(original_captain) and original_captain.is_inside_tree():
			real_world_scene.remove_child(original_captain)
			original_captain.queue_free()
		real_world_scene.queue_free()
		remove_child(real_world_scene)

func test_trigger_event_called_on_interaction() -> void:
	captain.player_inside = true
	Input.action_press("ui_accept")
	await wait_frames(2)
	assert_call_count(captain, "trigger_event", 1)
	Input.action_release("ui_accept")

func test_trigger_event_direct_call() -> void:
	captain.trigger_event()
	assert_call_count(captain, "trigger_event", 1)
