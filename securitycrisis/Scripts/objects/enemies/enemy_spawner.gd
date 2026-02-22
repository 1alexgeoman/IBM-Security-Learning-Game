extends Node2D

class_name Enemy_Spawner

signal next_wave(wave_number)

@export var idle_path: Path2D

@export var follow_path: PathFollow2D

@export var spawn_nodes: Node
var spawn_points: Array[Marker2D]
var spawn_points_i: int = 0

const ROUND_MAX = 10
var round = 0
var wave = 0;

var delay_delta = 0

const UPDATE_DELTA_MAX = 0.25
var update_delta = 0

const ENEMY_SPAWN_DELTA_MAX = 0.5
var enemy_spawn_delta = 0

const GROUP_SPAWN_DELTA_MAX= 1
var group_spawn_delta= 0

var wave_enemies: Array[Enemy] = []
var current_round: Array
var current_wave: Dictionary

var enemies: Array
var group_c: int

var total_round_damage: int = 0
var total_defences_destroyed: int = 0
var round_time: float = 0

@onready var round_label: Label = $DebugUI/RoundLabel
@onready var wave_label: Label = $DebugUI/WaveLabel
@onready var score_label: Label = $DebugUI/ScoreLabel

enum State {
	READY,
	SPAWNING_WAVE,
	WAVE_WAITING,
	ROUND_END
}

var state: State = State.READY

# array
const ROUND_DATA: Array[Array] = [
[
		# round 0 wave 0 spawn 3 enemy1s, and 2 enemy2s. With a max wait time of 10 seconds before spawning the next wave
		#Round 0 - DDOS_SPAM
		{
			"enemies": [[ENEMIES.DDOS_SPAM, 20]],
			"max-delay": 15,
			"groups": [
				[[ENEMIES.DDOS_SPAM, 3], [ENEMIES.DDOS_SPAM,3]],
				[[ENEMIES.DDOS_SPAM, 4],[ENEMIES.DDOS_SPAM, 3]],
				[[ENEMIES.DDOS_SPAM, 4],[ENEMIES.DDOS_SPAM, 3]]
			]
		},
		{
			"enemies": [[ENEMIES.DDOS_SPAM, 25]],
			"groups": [
				[[ENEMIES.DDOS_SPAM, 4], [ENEMIES.DDOS_SPAM,6]],
				[[ENEMIES.DDOS_SPAM, 6]],
				[[ENEMIES.DDOS_SPAM, 4],[ENEMIES.DDOS_SPAM, 3]],
				[[ENEMIES.DDOS_SPAM, 4],[ENEMIES.DDOS_SPAM, 3]],
			]
		}
	],

	# ROUND 1 – MALWARE/VIRUS
	[
		{
			"enemies": [[ENEMIES.MALWARE_VIRUS, 12],[ENEMIES.DDOS_SPAM, 15]],
			"max-delay": 15,
			"groups": [
				[[ENEMIES.DDOS_SPAM, 4], [ENEMIES.MALWARE_VIRUS, 2]],
			]
		},
		{
			"enemies": [[ENEMIES.MALWARE_VIRUS, 10], [ENEMIES.DDOS_SPAM, 10]],
			"groups": [
				[[ENEMIES.DDOS_SPAM, 4], [ENEMIES.MALWARE_VIRUS, 5]],
				[[ENEMIES.DDOS_SPAM, 4]]
			]
		}
	],

	# ROUND 2 – PHISHING
	[
		{
			"enemies": [[ENEMIES.PHISHING, 7], [ENEMIES.MALWARE_VIRUS, 10],[ENEMIES.DDOS_SPAM, 8]],
			"max-delay": 15,
			"groups": [
				[[ENEMIES.PHISHING, 3], [ENEMIES.MALWARE_VIRUS, 3], [ENEMIES.DDOS_SPAM, 6]]
			]
		},
		{
			"enemies": [[ENEMIES.DDOS_SPAM, 10], [ENEMIES.PHISHING, 7],[ENEMIES.DDOS_SPAM, 8]], 
			"groups": [
				[[ENEMIES.PHISHING, 4], [ENEMIES.MALWARE_VIRUS, 4]],
				[[ENEMIES.PHISHING, 5], [ENEMIES.DDOS_SPAM, 8]]
			]
		}
	],

	# ROUND 3 – MALWARE/TROJAN
	[
		{
			"enemies": [[ENEMIES.MALWARE_TROJAN, 4], [ENEMIES.MALWARE_VIRUS, 5],[ENEMIES.DDOS_SPAM, 8]],
			"max-delay": 18,
			"groups": [
				[[ENEMIES.MALWARE_TROJAN, 3], [ENEMIES.PHISHING, 6]]
			]
		},
		{
			"enemies": [[ENEMIES.MALWARE_TROJAN, 6], [ENEMIES.DDOS_SPAM, 6], [ENEMIES.PHISHING, 7]],
			"groups": [
				[[ENEMIES.MALWARE_TROJAN, 2], [ENEMIES.DDOS_SPAM, 8]],
				[[ENEMIES.MALWARE_TROJAN, 3]]
			]
		}
	],

	# ROUND 4 – SQL INJECTION
	[
		{
			"enemies": [[ENEMIES.SQL_INJECTION, 4], [ENEMIES.MALWARE_VIRUS, 2],[ENEMIES.DDOS_SPAM, 8]],
			"max-delay": 18,
			"groups": [
				[[ENEMIES.SQL_INJECTION, 3],[ENEMIES.MALWARE_TROJAN, 4]],
				[ [ENEMIES.DDOS_SPAM, 10]]
			]
		},
		{
			"enemies": [[ENEMIES.SQL_INJECTION, 5], [ENEMIES.MALWARE_TROJAN, 4], [ENEMIES.PHISHING, 4],[ENEMIES.MALWARE_VIRUS, 4],[ENEMIES.DDOS_SPAM, 8]],
			"groups": [
				[[ENEMIES.SQL_INJECTION, 3], [ENEMIES.MALWARE_TROJAN, 3]],
				[[ENEMIES.PHISHING, 4], [ENEMIES.MALWARE_VIRUS, 5], [ENEMIES.DDOS_SPAM, 10]]
			]
		}
	],




	# MAIN MENU ROUNDS
	#Round 5
	[	
		{
			"enemies": [[ENEMIES.MALWARE_VIRUS, 5], [ENEMIES.DDOS_SPAM, 24], [ENEMIES.PHISHING, 8], [ENEMIES.MALWARE_TROJAN, 4]],
			"max-delay": 30,
			"groups": [
				[[ENEMIES.MALWARE_VIRUS, 2], [ENEMIES.DDOS_SPAM, 3]],
				[[ENEMIES.DDOS_SPAM, 8]]
			]
		},
		{
			"enemies": [[ENEMIES.MALWARE_VIRUS, 4], [ENEMIES.DDOS_SPAM, 40], [ENEMIES.PHISHING, 14], [ENEMIES.SQL_INJECTION, 4]],
			"groups": [
				[[ENEMIES.MALWARE_VIRUS, 5], [ENEMIES.DDOS_SPAM, 10]],
				[[ENEMIES.DDOS_SPAM, 15]]
			]
		}
	],
	#Round 6
	[
		{
			"enemies": [[ENEMIES.MALWARE_VIRUS, 6], [ENEMIES.DDOS_SPAM, 24], [ENEMIES.PHISHING, 8], [ENEMIES.MALWARE_TROJAN, 4]],
			"max-delay": 30,
			"groups": [
				[[ENEMIES.MALWARE_VIRUS, 2], [ENEMIES.DDOS_SPAM, 6]],
				[[ENEMIES.DDOS_SPAM, 8]]
			]
		},
		{
			"enemies": [[ENEMIES.MALWARE_VIRUS, 4], [ENEMIES.DDOS_SPAM, 40], [ENEMIES.PHISHING, 14], [ENEMIES.MALWARE_TROJAN, 8]],
			"groups": [
				[[ENEMIES.MALWARE_VIRUS, 5], [ENEMIES.DDOS_SPAM, 10]],
				[[ENEMIES.DDOS_SPAM, 15], [ENEMIES.DDOS_SPAM, 5]],
				[[ENEMIES.DDOS_SPAM, 10]],
				[[ENEMIES.DDOS_SPAM, 12]]
			]
		}
	],
	#Round 7
		[
		{
			"enemies": [[ENEMIES.MALWARE_VIRUS, 5], [ENEMIES.MALWARE_VIRUS, 2]],
			"max-delay": 20
		},
		{
			"enemies": [[ENEMIES.MALWARE_VIRUS, 4], [ENEMIES.MALWARE_VIRUS, 4], [ENEMIES.MALWARE_VIRUS, 2]]
		}
	],
	#Round 8
		[
		{
			"enemies": [[ENEMIES.MALWARE_VIRUS, 5], [ENEMIES.MALWARE_VIRUS, 2]],
			"max-delay": 20
		},
		{
			"enemies": [[ENEMIES.MALWARE_VIRUS, 4], [ENEMIES.MALWARE_VIRUS, 4], [ENEMIES.MALWARE_VIRUS, 2]]
		}
	],
	#Round 9
		[
		{
			"enemies": [[ENEMIES.MALWARE_VIRUS, 5], [ENEMIES.MALWARE_VIRUS, 2]],
			"max-delay": 20
		},
		{
			"enemies": [[ENEMIES.MALWARE_VIRUS, 4], [ENEMIES.MALWARE_VIRUS, 4], [ENEMIES.MALWARE_VIRUS, 2]]
		}
	],

	#Round 10
		[
		{
			"enemies": [[ENEMIES.MALWARE_VIRUS, 5], [ENEMIES.MALWARE_VIRUS, 2]],
			"max-delay": 20
		},
		{
			"enemies": [[ENEMIES.MALWARE_VIRUS, 4], [ENEMIES.MALWARE_VIRUS, 4], [ENEMIES.MALWARE_VIRUS, 2]]
		}
	],
]

func spawn_enemy_at(enemy, pos: Vector2) -> bool:
	var e_scene: PackedScene = Enemy_data.get_enemy(enemy)
	if (e_scene == null):
		printerr("Unable to find enemy in enemy data")
		return false

	var e = e_scene.instantiate()
	if (e == null):
		printerr("Unable to instantiate enemy in spawn_enemy")
		return false

	e.position = pos

	add_child(e)

	return true

func spawn_enemy(enemy):
	return spawn_enemy_at(enemy, get_spawn_point())

func spawn_next_enemy() -> bool:
	if enemies.is_empty():
		
		return false

	var enemy_index = randi_range(0, enemies.size() - 1)
	var enemy = enemies.pop_at(enemy_index)

	spawn_enemy(enemy)

	return true

func spawn_next_group() -> bool:

	if (!current_wave.has("groups")):
		return false;

	if group_c >= current_wave.groups.size():
		return false

	var group: Array= current_wave.groups[group_c]
	group_c += 1

	for sub_group in group:
		var general_point: Vector2= get_spawn_point()
			
		var type= sub_group[0]
		var count: int= sub_group[1]

		for i in range(count):
			if (!spawn_enemy_at(type, general_point + get_group_spawn_offset(count))):
				return false

	return true

func get_group_spawn_offset(count: int) -> Vector2:
	var s: float= max(1, count as float / 4)
	return Vector2(randf_range(-32, 32), randf_range(-32, 32)) * s

func get_spawn_point() -> Vector2:
	if follow_path != null:
		follow_path.progress_ratio = randf() * 100

		return follow_path.position
	elif spawn_points != null && spawn_points.size() > 0:
		var point: Marker2D = spawn_points[spawn_points_i]

		spawn_points_i = (spawn_points_i + 1) % spawn_points.size()

		return point.position;
	else:
		printerr("No spawn information given. Requires follow path or spawn points array in enemy spawner to be linked. Spawning enemy at (0,0)")
		return Vector2(0,0)

func all_enemies_dead() -> bool:
	return get_tree().get_nodes_in_group("Enemies").is_empty()

func over_max_delay() -> bool:
	if !current_wave.has("max-delay"):
		return false
	
	return delay_delta >= current_wave["max-delay"]

func set_round(new_round: int) -> bool:
	round = new_round
	
	if round>= ROUND_MAX: 
		round_label.text = "Round: ROUNDS_END"
		return false 

	round_label.text = "Round: %d" % (round+1)

	if round < 0 || round >= ROUND_DATA.size():
		round_label.text = "Round: ROUNDS_END"
		return false;

	current_round = ROUND_DATA[round]
	state = State.SPAWNING_WAVE
	return true

func set_wave(new_wave) -> bool:
	
	wave = new_wave
	delay_delta = 0

	group_c= 0

	next_wave.emit(new_wave)

	wave_label.text = "Wave: %d" % (wave+1)

	if wave >= current_round.size():
		wave_label.text = "Wave: WAVES_END"
		return false;

	current_wave = current_round[wave]

	enemies.clear()
	for enemy_data in current_wave["enemies"]:
		var enemy_count = enemy_data[1]
		for j in range(enemy_count):
			enemies.append(enemy_data[0])

	return true

func update_wave() -> void:
	if all_enemies_dead() || over_max_delay():
		if !set_wave(wave + 1):
			state= State.ROUND_END
			round_end()
			return
		state= State.SPAWNING_WAVE
		return

	state= State.WAVE_WAITING
	return

func update_wave_spawn() -> bool:
	var single_ret: bool= true
	var group_ret: bool= true

	if enemy_spawn_delta >= ENEMY_SPAWN_DELTA_MAX:
		enemy_spawn_delta = 0
		single_ret = spawn_next_enemy()

	if group_spawn_delta >= GROUP_SPAWN_DELTA_MAX:
		group_spawn_delta= 0
		group_ret = spawn_next_group()

	return single_ret || group_ret

func update_round() -> void:
	match state:
		State.READY, State.ROUND_END:
			return

		State.SPAWNING_WAVE:
			if !update_wave_spawn():
				state = State.WAVE_WAITING

		State.WAVE_WAITING:
			update_wave()
				
func process_round(delta: float) -> void:
	# This script is to manage the spawning of the enemies
	# Main goals:
	#   - Find random points along the path 2d to spawn enemies
	#   - When a new round starts spawn the first wave based on ^
	#   - When either all enemies are dead (check on update_delta basis) or the max delay of the wave has passed (if set)

	update_delta += delta
	enemy_spawn_delta += delta
	delay_delta += delta
	group_spawn_delta += delta

	round_time += delta

	if update_delta >= UPDATE_DELTA_MAX:
		update_delta = 0

		update_round()

#todo once todo in loop below is done can change back to lambdas
func damage_callback(amount):
	total_round_damage += amount

func destroy_callback():
	total_defences_destroyed += 1

func reset(new_round: int) -> void:
	state = State.READY

	round_time = 0
	total_round_damage = 0
	total_defences_destroyed = 0

	for defence in get_tree().get_nodes_in_group("Defences") + get_tree().get_nodes_in_group("Auxiliary_Defences"):
		#todo change to loading these once the attacking being; this is only needed at the moment as ready doesn't have the defences loaded
		if not defence.defence_damaged.is_connected(damage_callback):
			defence.defence_damaged.connect(damage_callback)

		if not defence.defence_destroyed.is_connected(destroy_callback):
			defence.defence_destroyed.connect(destroy_callback)


	set_round(new_round)
	set_wave(0)

func start_round(new_round: int) -> void:
	reset(new_round)

func next_round() -> void:
	# So now round increments based on overall current round
	if (round+GameManager.current_round) >= ROUND_MAX:
		round_label.text = "Round: ROUNDS_END"
		return 
	reset(round + GameManager.current_round)

func calculate_round_score() -> int:
	return max(0, 1000 - round_time - total_round_damage - 10*total_defences_destroyed)

func update_score_label(round_score: int, round_time: float, round_damage: int) -> void:
	var total_score = GameManager.get_score_points()
	score_label.text = "Score: %d (Round score: %d, time: %d, damage: %d, destroyed: %d)" % [total_score, round_score, round_time, round_damage, total_defences_destroyed]

func round_end() -> void:
	var round_score = calculate_round_score()
	GameManager.add_score_points(round_score)
	update_score_label(round_score, round_time, total_round_damage)
	# When round has ended
	get_parent().end_game(true)

func _process(delta: float) -> void:
	process_round(delta)

func _ready() -> void:
	spawn_points= []
	if spawn_nodes != null:
		for child in spawn_nodes.get_children():
			spawn_points.append(child as Marker2D)
