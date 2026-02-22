extends Node2D


@onready var main_components = $MainComponents
@onready var animation = $MainComponents/Ui/SceneTransitionAnimation/AnimationPlayer
@onready var player = $MainComponents/Player
@onready var main_camera = $MainComponents/MainCamera



var opening_scene: Node = null
var playing: bool = false
var preview_playing: bool = false
var dialogue_playing: bool = false
var zoom: float = 0.7
var camera: Camera2D = null

## Animation const
const FADE_IN: StringName = "fade_in"
const FADE_OUT: StringName = "fade_out"
const ALERT_IN: StringName = "alerts/alert_fade_in"
const ALERT_OUT: StringName = "alerts/alert_fade_out"
const NEXT_DAY: StringName = "alerts/next_day"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var game = get_parent()
	if game.scene_file_path == "res://game.tscn"  and \
	GameManager.current_round == 0 and				 \
	!GameManager.opening_played:
		_opening_scene_start()
	if GameManager.current_round >= 4:
		_remove_captain()
	
	Dialogic.signal_event.connect(_on_variable_changed)

	await play_animation(FADE_OUT, 0.7)

func _process(_delta: float) -> void:
	if preview_playing and camera:
		zoom += 0.004
		camera.zoom = Vector2(zoom,zoom)
		if zoom >= 1.6:
			preview_playing = false
			_opening_scene_end()
	if GameManager.reactor_destroyed:
		await play_animation(ALERT_OUT, 0.5)
		

	
func _opening_scene_start():
	GameManager.opening_played = true
	#initiating scene
	opening_scene = load("res://Scenes/MainScenes/opening_scene.tscn").instantiate()
	opening_scene.position = Vector2(320, 390)
	add_child(opening_scene)
	
	#setting camera
	camera = opening_scene.get_node("Camera2D")
	camera.make_current()
	
	#setting skip button
	var skipButton = opening_scene.get_node("CanvasLayer/Skip")
	skipButton.pressed.connect(func():
		playing = false
		Dialogic.end_timeline()
		
		await play_animation(ALERT_IN,0)
		await play_animation(FADE_IN, 1)
		_opening_scene_end())
	
	playing = true
	main_components.visible = false
	player.disable_movement = true
	
	while playing:
		await play_animation(ALERT_IN, 0.5)
		if !dialogue_playing:
			dialogue_playing = true
			Dialogic.start("opening_timeline")
		await play_animation(ALERT_OUT, 0.5)
	
func _on_variable_changed(argument: String):
	if argument == "stop":
		playing = false
	if argument == "next_day":
		preview()
		
	
func _opening_scene_end():
	playing = false
	main_components.visible = true
	main_camera.make_current()
	player.disable_movement = false
	remove_child(opening_scene)
	await play_animation(FADE_OUT, 0.5)
	
	$MainComponents/Ui/Hint.add_hint("To interact with NPCs and objects press 'E' or 'Enter'")
	
func preview():
	opening_scene.get_node("CanvasLayer").visible = false
	await play_animation(FADE_IN, 0.5)
	$OpeningScene/NPCs.visible = false
	# quickly changes to this camera to centralise scene
	$MainComponents/Ui/SceneTransitionAnimation/Camera2D.make_current()

	await play_animation(NEXT_DAY, 5.0)
	
	
	camera.make_current()

	await play_animation(FADE_OUT, 0.5)
	
	if camera:
		camera.zoom = Vector2(zoom, zoom)
		preview_playing = true


func _remove_captain() -> void:
	remove_child($MainComponents/CaptainNPC)
	$MainComponents/CaptainNPC.queue_free()


func play_animation(animation_name: StringName, duration: float) -> void:
	animation.play(animation_name)
	await get_tree().create_timer(duration).timeout
	
