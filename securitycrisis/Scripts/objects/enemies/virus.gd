extends Enemy

const virus_scene = preload("res://Scenes/objects/Enemies/Virus.tscn")
const wave_map = preload("res://Scenes/Maps/wave_map.tscn")

enum VirusState {
	V_ATTACK,
	V_SPLITTING
}

enum VirusStyle {
	SPLITTER,
	TROOPER
}

var max_splitting_delta: float = 3
const MAX_SPLITTING_DELTA_INC: float = 1
var splitting_delta: float = 0

var max_time_to_split: float = 12
const MAX_TIME_TO_SPLIT_INC: float = 1
var time_to_split = 0

const POSITION_OFFSET= Vector2(30,0)

var state: VirusState = VirusState.V_ATTACK
var style: VirusStyle = VirusStyle.SPLITTER

var idle_target: Vector2 = Vector2(0,0)
const MAX_IDLE_TARGET_DELTA: float = 5 # every 5 seconds move to another idle target
var idle_target_delta: float = MAX_IDLE_TARGET_DELTA

const TROOPER_STYLE_CHANCE_INC: float = 0.15
var trooper_style_chance: float = 1

const MAX_IDLE_TARGET_OFFSET: float = 0.1

func _ready() -> void:
	super._ready()
	style= VirusStyle.SPLITTER if randf() <= 0.5 else VirusStyle.TROOPER

func configure_child_virus(
		max_splitting_delta_: float,
		max_time_to_split_: float,
		global_pos: Vector2,
		trooper_style_chance_: float
	) -> void:
	max_splitting_delta= max_splitting_delta_
	max_time_to_split= max_time_to_split_
	trooper_style_chance= trooper_style_chance_

	global_position= global_pos

	var r= randf() * trooper_style_chance_
	style= VirusStyle.SPLITTER if r <= 0.2 else VirusStyle.TROOPER

func switch_state(new_state: VirusState):
	match new_state:
		VirusState.V_ATTACK:
			$AnimationPlayer.stop()
		VirusState.V_SPLITTING:
			$AnimationPlayer.play("virus-splitting")
			vel= Vector2(0,0)
	state= new_state

func split() -> void:
	var pos = global_position
	var left = pos - POSITION_OFFSET
	var right = pos + POSITION_OFFSET

	var new_virus = virus_scene.instantiate()
	new_virus.configure_child_virus(max_splitting_delta + MAX_SPLITTING_DELTA_INC, max_time_to_split + MAX_TIME_TO_SPLIT_INC, left, trooper_style_chance + TROOPER_STYLE_CHANCE_INC)
	global_position= right

	get_parent().add_child(new_virus)

func process_split(delta: float) -> void:
	splitting_delta+= delta

	if (splitting_delta >= max_splitting_delta):
		split()

		splitting_delta = 0
		switch_state(VirusState.V_ATTACK)

func find_idle_path_location() -> void:
	var path: Path2D= get_parent().idle_path
	var follow: PathFollow2D= path.get_node("PathFollow2D")

	var closest_path_offset= path.curve.get_closest_offset(path.to_local(global_position)) / path.curve.get_baked_length()

	closest_path_offset+= randf_range(-MAX_IDLE_TARGET_OFFSET, MAX_IDLE_TARGET_OFFSET)
	closest_path_offset= wrapf(closest_path_offset, 0, 1)

	follow.progress_ratio= closest_path_offset

	idle_target= follow.global_position

func process_splitter_idle(delta: float) -> void:
	idle_target_delta+= delta

	if idle_target_delta >= MAX_IDLE_TARGET_DELTA:
		idle_target_delta= 0

		find_idle_path_location()

	move_towards(idle_target, delta)

func process_splitter_style(delta: float) -> void:
	time_to_split+= delta

	if time_to_split >= max_time_to_split:
		time_to_split = 0
		max_time_to_split += MAX_TIME_TO_SPLIT_INC

		switch_state(VirusState.V_SPLITTING)

	match state:
		VirusState.V_SPLITTING:
			process_split(delta)
		VirusState.V_ATTACK:
			process_splitter_idle(delta)

func _process(delta: float) -> void:
	match style:
		VirusStyle.SPLITTER:
			process_splitter_style(delta)
		VirusStyle.TROOPER:
			process_actions(delta)
