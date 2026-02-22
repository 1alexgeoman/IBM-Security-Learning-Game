extends GutTest

var real_world_scene: Node2D
var player: CharacterBody2D
var shop: Area2D
var shop_ui: Control
var original_shop: Area2D

func before_all() -> void:
	var scene_packed = load("res://Scenes/Maps/real_world_map.tscn")
	real_world_scene = scene_packed.instantiate()
	add_child(real_world_scene)

func before_each() -> void:
	player = real_world_scene.get_node("MainComponents/Player")
	original_shop = real_world_scene.get_node("%Shop")
	shop_ui = real_world_scene.get_node("%ShopUI")  
	
	# Double the part of creating a shop
	var shop_script = load("res://Scripts/objects/shop.gd")
	shop = partial_double(shop_script).new()
	
	shop.player = player
	shop.player_inside = true
	
	real_world_scene.remove_child(original_shop)
	real_world_scene.add_child(shop)
	
	# Monitor the trigger_event call
	stub(shop, "trigger_event").to_do_nothing()

func after_each() -> void:
	if is_instance_valid(shop):
		real_world_scene.remove_child(shop)
		shop.queue_free()
	
	if is_instance_valid(original_shop) and not original_shop.is_inside_tree():
		real_world_scene.add_child(original_shop)

func after_all() -> void:
	if is_instance_valid(real_world_scene):
		if is_instance_valid(original_shop) and original_shop.is_inside_tree():
			real_world_scene.remove_child(original_shop)
			original_shop.queue_free()
		real_world_scene.queue_free()

func test_trigger_event_called_on_interaction() -> void:
	shop.player_inside = true
	Input.action_press("ui_accept")
	await wait_frames(2)
	assert_call_count(shop, "trigger_event", 1)
	Input.action_release("ui_accept")

func test_trigger_event_direct_call() -> void:
	shop.trigger_event()
	assert_call_count(shop, "trigger_event", 1)
