extends Control

func _on_back_pressed() -> void:
	GameManager.change_scene(GameManager.START_MENU_SCENE)
