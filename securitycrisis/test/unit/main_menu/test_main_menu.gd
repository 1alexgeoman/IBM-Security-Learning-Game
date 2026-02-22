extends GutTest

var game_scene: Node
var game_manager: Node
var main_menu: Control
var start_button: TextureButton

func before_all() -> void:
	game_manager = get_node("/root/GameManager")
	
	# Create game node as scene container
	var game_node = autoqfree(Node.new())
	game_manager.current_scene_node = game_node
	add_child_autofree(game_node)
	
	#Load game scene
	var game_scene_packed = load("res://game.tscn")
	game_scene = autoqfree(game_scene_packed.instantiate())
	game_node.add_child(game_scene)
	
func before_each() -> void:
	#Get MainMenu instance and start button
	main_menu = game_scene.get_node("MainMenu")
	assert_not_null(main_menu, "MainMenu should exist in game scene")

	start_button = main_menu.get_node("%GameStart")
	assert_not_null(start_button, "Start button should exist in MainMenu")

func test_game_start_button_changes_scene() -> void:
	assert_not_null(game_manager.current_scene_node, "current_scene_node should be initialized")
	start_button.emit_signal("pressed")
	
	assert_true(game_manager.game_start, "GameManager.game_start should be true")
	
	await wait_frames(1)
	
	# Verify that the scenario has been switched
	var current_child = game_manager.current_scene_node.get_child(0)
	assert_not_null(current_child, "New scene should be instantiated")
	assert_ne(current_child.scene_file_path, "res://Scenes/UIScenes/main_menu.tscn",
			 "Should no longer be main menu scene")
			
	#  Ensure that the real_world_map scene is loaded
	if current_child != null:
		assert_eq(current_child.scene_file_path, "res://Scenes/Maps/real_world_map.tscn",
			"Should have switched to real_world_map scene")
