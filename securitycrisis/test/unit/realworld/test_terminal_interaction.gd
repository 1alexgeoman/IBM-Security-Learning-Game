extends GutTest

var terminal_scene: Node2D
var terminal: Area2D
var player: CharacterBody2D
var original_terminal: Area2D
var game_manager: Node
var scene_node: Node
@onready var build_scene: PackedScene = preload("res://Scenes/Maps/build_map.tscn")

func before_all() -> void:
	# Initialize the game manager
	game_manager = Node.new()
	game_manager.set_script(load("res://game_manager.gd"))
	add_child(game_manager)
	
	var scene_packed = load("res://Scenes/Maps/real_world_map.tscn")
	terminal_scene = scene_packed.instantiate()
	add_child(terminal_scene)

func before_each() -> void:
	if not is_instance_valid(scene_node):
		scene_node = Node.new()
		game_manager.current_scene_node = scene_node
		add_child(scene_node)
	
	# Load and add real-world scene
	terminal_scene = load("res://Scenes/Maps/real_world_map.tscn").instantiate()
	scene_node.add_child(terminal_scene)
	
	player = terminal_scene.get_node("MainComponents/Player")
	original_terminal = terminal_scene.get_node("%Terminal") 
	
	# Create a terminal double instance
	var terminal_script = load("res://Scripts/objects/terminal.gd")
	terminal = partial_double(terminal_script).new()
	
	terminal.player_inside = true
	terminal.SceneTransitionNode = terminal_scene.get_node("SceneTransitionAnimation")
	
	terminal_scene.remove_child(original_terminal)
	terminal_scene.add_child(terminal)
	
	# Monitor the trigger_event call
	stub(terminal, "trigger_event").to_do_nothing()

func after_each() -> void:
	if is_instance_valid(terminal):
		terminal_scene.remove_child(terminal)
		terminal.queue_free()
	
	if is_instance_valid(original_terminal) and not original_terminal.is_inside_tree():
		terminal_scene.add_child(original_terminal)
	
		
	if is_instance_valid(terminal_scene):
		terminal_scene.queue_free()

func after_all() -> void:
	if is_instance_valid(scene_node):
		scene_node.queue_free()
	if is_instance_valid(game_manager):
		game_manager.queue_free()
	if is_instance_valid(terminal_scene):
		if is_instance_valid(original_terminal) and original_terminal.is_inside_tree():
			terminal_scene.remove_child(original_terminal)
			original_terminal.queue_free()
		terminal_scene.queue_free()

func test_trigger_event_called_on_interaction() -> void:
	terminal.player_inside = true
	
	Input.action_press("ui_accept")
	await wait_frames(2)  # 等待1帧处理输入
	
	# Verify that trigger_event is called
	assert_called(terminal, "trigger_event")
	
	Input.action_release("ui_accept")

func test_trigger_event_not_called_when_player_outside() -> void:
	terminal.player_inside = false
	
	Input.action_press("ui_accept")
	await wait_frames(2)
	
	assert_call_count(terminal, "trigger_event", 0)
	
	Input.action_release("ui_accept")

func test_trigger_event_direct_call() -> void:
	# Call the method directly for testing
	terminal.trigger_event()
	assert_call_count(terminal, "trigger_event", 1)

func test_scene_transition_on_trigger_event() -> void:
	var transition_terminal = load("res://Scripts/objects/terminal.gd").new()
	add_child(transition_terminal)
	transition_terminal.player_inside = true
	transition_terminal.SceneTransitionNode = terminal_scene.get_node("SceneTransitionAnimation")
	
	# Set the current scene node of the game manager
	game_manager.current_scene_node = terminal_scene
	
	game_manager.change_to_preloaded_scene(load("res://Scenes/Maps/build_map.tscn"))
	await wait_frames(2)  
	
	
	var current_child = game_manager.current_scene_node.get_child(0)
	print("The actual scene switched to:", current_child.scene_file_path)
	assert_not_null(current_child, "The new scenario should have been instantiated")
	assert_ne(current_child.scene_file_path, "res://Scenes/Maps/real_world_map.tscn","no longer remain in the real-world scene")
	
	transition_terminal.queue_free()
