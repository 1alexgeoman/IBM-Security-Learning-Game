extends NPC

var played_timeline: bool= false
var played_reactor: bool= false

func _ready() -> void:
	super._ready()

	played_timeline= false
	played_reactor= false

func has_dialog() -> bool:
	var has_timeline= not GameManager.reactor_destroyed and not played_timeline
	var has_reactor= GameManager.reactor_destroyed and not played_reactor

	return has_timeline or has_reactor

func interact_event():
	if Dialogic.current_timeline != null:
		return

	if GameManager.reactor_destroyed:
		if GameManager.current_round == 4:
			Dialogic.start("hints4")
		Dialogic.start("reactor_destroyed")
		played_reactor= true
	if  get_parent().scene_file_path == "res://Scenes/MainScenes/question_scene.tscn":
		Dialogic.start("neutronQuestion")
	else:
		Dialogic.start("neutronTimeline%d" %GameManager.current_round)
		played_timeline= true
