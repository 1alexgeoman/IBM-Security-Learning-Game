extends GutTest

var real_world_scene: Node2D
var player: CharacterBody2D
var captain: Area2D
var captain_sprite: Sprite2D

func before_all() -> void:
	# Load the real_world scene
	var scene_packed = load("res://Scenes/Maps/real_world_map.tscn")
	real_world_scene = scene_packed.instantiate()
	add_child(real_world_scene)

func before_each() -> void:
	player = real_world_scene.get_node("MainComponents/Player")
	captain = real_world_scene.get_node("%CaptainNPC")
	captain_sprite = captain.get_node("Sprite2D")
	
	captain_sprite.modulate = Color(1,1,1)
	captain.player_inside = false
	
	assert_not_null(player, "Player should exist")
	assert_not_null(captain, "Captain should exist")
	assert_not_null(captain_sprite, "Captain Sprite should exist")

func after_all() -> void:
	if is_instance_valid(real_world_scene):
		remove_child(real_world_scene)
		real_world_scene.queue_free()
		await get_tree().process_frame

func test_terminal_color_changes_when_player_enters() -> void:
	# The initial color should be white
	assert_eq(captain_sprite.modulate, Color(1,1,1))
	
	captain._on_body_entered(player)
	await wait_frames(1)
	
	# The verification color turns red
	assert_eq(captain_sprite.modulate, Color(0,1,0), "The color changes to green after the player enters")

func test_terminal_color_restores_when_player_exits() -> void:
	captain._on_body_entered(player)
	await wait_frames(1)
	assert_eq(captain_sprite.modulate, Color(0,1,0), "It should be green after entering")
	
	captain._on_body_exited(player)
	await wait_frames(1)
	
	# Verify that the color returns to white
	assert_eq(captain_sprite.modulate, Color(1,1,1), "The color should return to white after the player leaves")
