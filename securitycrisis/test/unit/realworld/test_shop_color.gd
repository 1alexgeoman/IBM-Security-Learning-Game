extends GutTest

var real_world_scene: Node2D
var player: CharacterBody2D
var shop: Area2D
var shop_sprite: Sprite2D

func before_all() -> void:
	# Load the real_world scene
	var scene_packed = load("res://Scenes/Maps/real_world_map.tscn")
	real_world_scene = scene_packed.instantiate()
	add_child(real_world_scene)

func before_each() -> void:
	player = real_world_scene.get_node("MainComponents/Player")
	shop = real_world_scene.get_node("%Shop")
	shop_sprite = shop.get_node("Sprite2D")
	
	shop_sprite.modulate = Color.WHITE
	shop.player = player
	shop.player_inside = false
	
	assert_not_null(player, "Player should exist")
	assert_not_null(shop, "Shop should exist")
	assert_not_null(shop_sprite, "Shop Sprite should exist")

func after_all() -> void:
	if is_instance_valid(real_world_scene):
		remove_child(real_world_scene)
		real_world_scene.queue_free()
		await get_tree().process_frame

func test_shop_color_changes_when_player_enters() -> void:
	# The initial color should be white
	assert_eq(shop_sprite.modulate, Color.WHITE)
	
	shop._on_body_entered(player)
	
	# The verification color turns red
	assert_eq(shop_sprite.modulate, Color.RED, "The color changes to red after the player enters")
	assert_true(shop.player_inside, "player_inside should be true")

func test_shop_color_restores_when_player_exits() -> void:
	shop._on_body_entered(player)
	assert_eq(shop_sprite.modulate, Color.RED, "It should be red after entering")
	
	shop._on_body_exited(player)
	
	# Verify that the color returns to white
	assert_eq(shop_sprite.modulate, Color.WHITE, "The color should return to white after the player leaves")
	assert_false(shop.player_inside, "player_inside should be false")
