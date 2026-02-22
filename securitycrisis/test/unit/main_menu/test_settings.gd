extends GutTest

var game_scene: Node
var game_manager: Node
var main_menu: Control
var settings_button: TextureButton

func before_all() -> void:
	game_manager = get_node("/root/GameManager")
	
	var game_node = autoqfree(Node.new())
	game_manager.current_scene_node = game_node
	add_child_autofree(game_node)
	
	# load game scene
	var game_scene_packed = load("res://game.tscn")
	game_scene = autoqfree(game_scene_packed.instantiate())
	game_node.add_child(game_scene)

func before_each() -> void:
	main_menu = game_scene.get_node("MainMenu")
	assert_not_null(main_menu, "MainMenu should exist in game scene")

	settings_button = main_menu.get_node("%Settings")
	assert_not_null(settings_button, "Settings button should exist in MainMenu")

func test_settings_button_changes_scene() -> void:
	assert_not_null(game_manager.current_scene_node, "current_scene_node should be initialized")
	
	# Verify button signal connection
	var callable = Callable(main_menu, "_on_settings_pressed")
	assert_true(settings_button.is_connected("pressed", callable),
		"Settings button should be connected to _on_settings_pressed method")
	
	settings_button.emit_signal("pressed")
	
	await wait_frames(2)
	
	# Verify that the scene has been switched
	var current_child = game_manager.current_scene_node.get_child(0)
	assert_not_null(current_child, "New scene should be instantiated")
	assert_ne(current_child.scene_file_path, "res://Scenes/UIScenes/main_menu.tscn",
			 "Should no longer be main menu scene")
	
	# Make sure switched to Settings
	if current_child != null:
		assert_eq(current_child.scene_file_path, GameManager.SETTINGS_SCENE,
				"Should have switched to settings scene")
