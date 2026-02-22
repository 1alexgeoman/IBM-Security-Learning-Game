extends Node2D

@onready var neutron_scene = "res://Scenes/Characters/neutron_npc.tscn"

func _ready() -> void:
	if GameManager.current_round >= 4:
		_changeCaptain()

	var animation = $SceneTransitionAnimation/AnimationPlayer
	animation.play("fade_out")
	await get_tree().create_timer(0.5).timeout
	
	Dialogic.timeline_started.connect(review_report)
	

func _changeCaptain() -> void:
	var neutron = load(neutron_scene).instantiate()
	add_child(neutron)
	neutron.global_position = $CaptainNPC.global_position
	remove_child($CaptainNPC)
	
	
func review_scene() -> void:
	GameManager.change_scene(GameManager.REVIEWED_REPORT_SCENE)
	
func review_report():
	if Dialogic.current_timeline.resource_name != "questionTimeline" :
		Dialogic.timeline_ended.connect(review_scene)
	
func safe_disconnect(signal_ref: Signal,method: Callable) -> void:
	if signal_ref.is_connected(method):
		signal_ref.disconnect(method)
		

func _exit_tree():
	safe_disconnect(Dialogic.timeline_started, review_report)
	safe_disconnect(Dialogic.timeline_ended, review_scene)
