extends GutTest

var real_world_scene: Node2D
var player: CharacterBody2D
var shop: Area2D
var shop_ui: Control

func before_all() -> void:
	# Load the real_world scene
	var scene_packed = load("res://Scenes/Maps/real_world_map.tscn")
	real_world_scene = autoqfree(scene_packed.instantiate())
	add_child_autofree(real_world_scene)

func before_each() -> void:
	player = real_world_scene.get_node("MainComponents/Player")
	shop = real_world_scene.get_node("%Shop")  
	shop_ui = real_world_scene.get_node("%ShopUI")  
	
	shop.player = player
	
	assert_not_null(player, "Player should exist in scene")
	assert_not_null(shop, "Shop area should exist in scene")
	assert_not_null(shop_ui, "ShopUI should exist in scene")
	assert_not_null(shop.player, "Shop's player reference should be set")
	shop.player_inside = true 

func test_shop_ui_shows_when_player_interacts() -> void:
	assert_false(shop_ui.visible, "ShopUI should start hidden")
	
	Input.action_press("ui_accept")
	await wait_frames(3)
	
	# Verify whether ShopUI is visible
	assert_true(shop_ui.visible, "ShopUI should be visible after interaction")
	
	# release
	Input.action_release("ui_accept")
