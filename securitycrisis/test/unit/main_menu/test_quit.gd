extends GutTest

var game_scene: Node
var main_menu: Control
var quit_button: TextureButton

func before_all() -> void:
	var game_scene_packed = load("res://game.tscn")
	game_scene = autoqfree(game_scene_packed.instantiate())
	add_child_autofree(game_scene)

func before_each() -> void:
	main_menu = game_scene.get_node("MainMenu")
	assert_not_null(main_menu, "MainMenu should exist in game scene")
	
	quit_button = main_menu.get_node("%Quit")
	assert_not_null(quit_button, "Quit button should exist in MainMenu")

func test_quit_button_exits_game() -> void:

	var callable = Callable(main_menu, "_on_quit_pressed")
	
	assert_true(quit_button.is_connected("pressed", callable),
		"Quit button should be connected to _on_quit_pressed method")
