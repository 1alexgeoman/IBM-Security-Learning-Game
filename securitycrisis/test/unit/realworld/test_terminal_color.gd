extends GutTest

var real_world_scene: Node2D
var player: CharacterBody2D
var terminal: Area2D
var terminal_sprite: Sprite2D

func before_all() -> void:
	# Load the real_world scene
	var scene_packed = load("res://Scenes/Maps/real_world_map.tscn")
	real_world_scene = scene_packed.instantiate()
	add_child(real_world_scene)

func before_each() -> void:
	player = real_world_scene.get_node("MainComponents/Player")
	terminal = real_world_scene.get_node("%Terminal")
	terminal_sprite = terminal.get_node("Sprite2D")
	
	terminal_sprite.modulate = Color(1,1,1)
	terminal.player_inside = false
	
	assert_not_null(player, "Player should exist")
	assert_not_null(terminal, "Terminal should exist")
	assert_not_null(terminal_sprite, "Terminal Sprite should exist")

func after_all() -> void:
	if is_instance_valid(real_world_scene):
		remove_child(real_world_scene)
		real_world_scene.queue_free()
		await get_tree().process_frame

func test_terminal_color_changes_when_player_enters() -> void:
	# The initial color should be white
	assert_eq(terminal_sprite.modulate, Color(1,1,1))
	
	terminal._on_body_entered(player)
	await wait_frames(1)
	
	# The verification color turns blue
	assert_eq(terminal_sprite.modulate, Color(0,0,1), "The color changes to blue after the player enters")

func test_terminal_color_restores_when_player_exits() -> void:
	terminal._on_body_entered(player)
	await wait_frames(1)
	assert_eq(terminal_sprite.modulate, Color(0,0,1), "It should be blue after entering")
	
	terminal._on_body_exited(player)
	await wait_frames(1)
	
	# Verify that the color returns to white
	assert_eq(terminal_sprite.modulate, Color(1,1,1), "The color should return to white after the player leaves")
