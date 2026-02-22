extends Node2D

var animation: AnimationPlayer = null

func _ready() -> void:
	animation = $SceneTransitionAnimation/AnimationPlayer
	animation.play("fade_out")
	Dialogic.start("end_timeline")
	
	Dialogic.timeline_started.connect(question)


	
func question_scene() -> void:
	GameManager.change_scene(GameManager.QUESTION_SCENE)
	
func question():
	if Dialogic.current_timeline.resource_name != "questionTimeline" :
		Dialogic.timeline_ended.connect(question_scene)
	
func safe_disconnect(signal_ref: Signal,method: Callable) -> void:
	if signal_ref.is_connected(method):
		signal_ref.disconnect(method)
		

func _exit_tree():
	safe_disconnect(Dialogic.timeline_started, question)
	safe_disconnect(Dialogic.timeline_ended, question_scene)
