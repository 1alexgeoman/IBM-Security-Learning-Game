# pausedmenu.gd
extends Control

const START_MENU := "res://Scenes/UIScenes/main_menu.tscn"

func _ready() -> void:
	# Hide at start, allow processing when paused
	visible    = false
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			_unpause_game()
		else:
			_pause_game()

func _pause_game() -> void:
	get_tree().paused = true
	visible           = true
	# show mouse if you need:
	# Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unpause_game() -> void:
	get_tree().paused = false
	visible           = false
	# lock mouse again:
	# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	


func _on_resume_pressed() -> void:
	_unpause_game() # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().paused=false # Replace with function body.
	GameManager.reset()
	GameManager.change_scene(GameManager.START_MENU_SCENE)
