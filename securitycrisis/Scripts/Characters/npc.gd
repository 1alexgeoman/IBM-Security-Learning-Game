extends StaticBody2D

class_name NPC

@export var dialog_marker_position: Marker2D

var in_range: bool= false

func interact_event() -> void:
	printerr("Event would play, but this is an abstract function")

func exit_event() -> void:
	printerr("Exit event called on abstract function")

func has_dialog() -> bool:
	printerr("has_dialog is an abstract function")
	return true

func _ready() -> void:
	$IcoSp.global_position= $Marker2D.global_position
	hide_ico()

func _process(_delta) -> void:
	if not in_range:
				return

	if Input.is_action_just_pressed("ui_exit"):
		exit_event()

	if Input.is_action_just_pressed("interact"):
		interact_event()

	update_dialoc_ico(true)
				
	get_viewport().set_input_as_handled()

func hide_ico() -> void:
	$IcoSp.visible=false
	$IcoAnimP.stop()

func show_ico() -> void:
		$IcoSp.visible=true
		$IcoAnimP.play("Default")

func update_dialoc_ico(try_show: bool) -> void:
	if not has_dialog():
		hide_ico()
		return

	if try_show:
		show_ico()
	else:
		hide_ico()

func _on_show_dialog_ico_body_entered(body) -> void:
	if body.is_in_group("Player") and body.is_visible_in_tree():
		update_dialoc_ico(true)
		in_range= true

func _on_show_dialog_ico_body_exited(body) -> void:
	if body.is_in_group("Player"):
		update_dialoc_ico(false)
		in_range=false
