extends NPC

var has_hints: bool= false
var shown_hint: bool= false

var has_questions: bool= false
var shown_questions: bool= false

func has_dialog() -> bool:
	return has_hints and not shown_hint or \
		has_questions and not shown_questions

func _ready() -> void:
	super._ready()

	if GameManager.current_round == 0 and get_parent().scene_file_path == "res://Scenes/MainScenes/question_scene.tscn":
		Dialogic.start("questionTimeline")
		Dialogic.VAR.set_variable("first_time", true)
	else:
		Dialogic.VAR.set_variable("first_time", false)

	if get_parent().scene_file_path == "res://Scenes/MainScenes/question_scene.tscn":
		has_questions= true

	if GameManager.reactor_destroyed:
		has_hints = true

func interact_event() -> void:
	if Dialogic.current_timeline != null:
			return
	
	if GameManager.current_round > 4:
		Dialogic.start("end_timeline")
	
	if get_parent().scene_file_path == "res://Scenes/MainScenes/question_scene.tscn":
		Dialogic.start("captainTimeline0")

		shown_questions= true
		
	
	if has_hints:
		Dialogic.start("hints%d" % GameManager.current_round)
		
		shown_hint= true
	else:
		Dialogic.start("default")
	
	await Dialogic.timeline_ended
	
