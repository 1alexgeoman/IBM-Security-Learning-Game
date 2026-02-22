extends GutTest

var game_scene: Node
var game_manager: Node
var main_menu: Control
var leaderboard_button: TextureButton

func before_all() -> void:
	game_manager = get_node("/root/GameManager")
	
	var game_node = autoqfree(Node.new())
	game_manager.current_scene_node = game_node
	add_child_autofree(game_node)
	
	var game_scene_packed = load("res://game.tscn")
	game_scene = autoqfree(game_scene_packed.instantiate())
	game_node.add_child(game_scene)

func before_each() -> void:
	#Get MainMenu instance and LeaderBoard button
	main_menu = game_scene.get_node("MainMenu")
	assert_not_null(main_menu, "MainMenu should exist in game scene")

	leaderboard_button = main_menu.get_node("%LeaderBoard")
	assert_not_null(leaderboard_button, "LeaderBoard button should exist in MainMenu")

func test_leaderboard_button_changes_scene() -> void:
	assert_not_null(game_manager.current_scene_node, "current_scene_node should be initialized")
	
	leaderboard_button.emit_signal("pressed")
	
	await wait_frames(1)
	
	# Verify that the scene has been switched
	var current_child = game_manager.current_scene_node.get_child(0)
	assert_not_null(current_child, "New scene should be instantiated")
	assert_ne(current_child.scene_file_path, "res://Scenes/UIScenes/main_menu.tscn",
			 "Should no longer be main menu scene")
	
	if current_child != null:
		assert_eq(current_child.scene_file_path, GameManager.LEADERBOARD_SCENE,
				"Should have switched to leaderboard scene")
