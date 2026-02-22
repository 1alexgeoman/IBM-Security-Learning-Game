extends Node

signal round_updated(new_round)
signal kp_changed(new_kp)

var available_defenses: Dictionary = {
	0: ["FIREWALL", "ANTI-MALWARE TURRET"],
	1: ["ANTI-VIRUS"],
	2: ["AI SPAM-FILTER"],
	3: ["TROJAN BUSTER"],
	4: ["SQL ENERVATOR"],
}

# Global game state
var knowledge_points: int = 1500  
var current_round: int = 0
var score_points: int = 0
var game_start: bool = false
var opening_played: bool = false
var reactor_destroyed: bool = false
var level_questions: Array = []
var index = 0
var responses: Array[String] = []
var answer

# Scene-specific state
var build_map_state: Array = [] 
var real_world_map_state: Dictionary = { "shop_played": false, "terminal_played": false}  

# Scene paths (for easy reference)
const START_MENU_SCENE: StringName = "res://Scenes/UIScenes/main_menu.tscn"
const REAL_WORLD_MAP_SCENE: StringName = "res://Scenes/Maps/real_world_map.tscn"
const BUILD_MAP_SCENE: StringName = "res://Scenes/Maps/build_map.tscn"
const WAVE_MAP_SCENE: StringName = "res://Scenes/Maps/wave_map.tscn"
const LEADERBOARD_SCENE: StringName = "res://Scenes/UIScenes/leaderboard.tscn"
const SETTINGS_SCENE: StringName = "res://Scenes/UIScenes/settings.tscn"
const SHOP_UI_SCENE: StringName = "res://scenes/UIScenes/shop_ui.tscn"
const Question_UI_SCENE: StringName = "res://scenes/UIScenes/question_ui.tscn"
const REVIEWED_REPORT_SCENE: StringName = "res://Scenes/UIScenes/reviewed_report.tscn"
const QUESTION_SCENE: StringName = "res://Scenes/MainScenes/question_scene.tscn"
const ENDING: StringName = "res://Scenes/MainScenes/ending_scene.tscn"
const THANK_YOU: StringName = "res://Scenes/UIScenes/thank_you.tscn"



var current_scene_node: Node

# Called when the GameManager is ready
func _ready() -> void:
	# Find the CurrentScene node in the game.tscn tree
	current_scene_node = get_tree().get_root().get_node("Game")
	# 在 game_manager.gd 中添加保护性检查和初始化方法
	init_current_scene_node()
	# Bind the knowledge point update with questions 
	QuestionManager.question_answered.connect(
		func(correct, _correct_answer): _on_question_answered(correct)
	)
	
# 添加一个公共初始化方法
func init_current_scene_node() -> void:
	if not is_instance_valid(current_scene_node):
		current_scene_node = get_tree().root.get_node("Game")

func get_unlocked_defenses() -> Array:
	var unlocked = []
	for i in range(current_round + 1):  # only derive the defneses of current round
		if available_defenses.has(i):
			unlocked.append_array(available_defenses[i])
	return unlocked

func start_next_round(current_round: int):
	round_updated.emit(current_round)  # send the signal to shopui to unlock new defenses of relevant round

# Change to a new scene
func change_scene(scene_path: String) -> void:
	# Remove the current scene (if any)
	var new_scene = load(scene_path).instantiate()
	current_scene_node.add_child(new_scene)
	var child = current_scene_node.get_child(0)
	child.queue_free()

func change_to_preloaded_scene(packed_scene: PackedScene) -> void:
	init_current_scene_node()  
	if not is_instance_valid(current_scene_node):
		push_error("current_scene_node is not initialized")
		return
	
	var new_scene = packed_scene.instantiate()
	current_scene_node.add_child(new_scene)
	

	var old_scene = current_scene_node.get_child(0)
	if is_instance_valid(old_scene) and old_scene != new_scene:
		old_scene.queue_free()

# Add knowledge points if answer is correct
func _on_question_answered(correct: bool):
	if correct:
		add_knowledge_points(50)

# Add Knowledge Points
func add_knowledge_points(amount: int) -> void:
	knowledge_points += amount
	kp_changed.emit(knowledge_points)

# Spend Knowledge Points
func spend_knowledge_points(amount: int) -> bool:
	if knowledge_points >= amount:
		knowledge_points -= amount
		kp_changed.emit(knowledge_points)
		return true
	else:
		return false

func add_score_points(amount: int) -> void:
	score_points += amount

func get_score_points() -> int:
	return score_points

# Save the state of the build_map.tscn (e.g., placed defenses)
func save_build_map_state(defenses: Array) -> void:
	build_map_state = defenses

# Load the state of the build_map.tscn
func load_build_map_state() -> Array:
	return build_map_state

# Save the state of the real_world_map.tscn (e.g., NPC interactions, collected items)
func save_real_world_map_state(Key: String, Value) -> void:
	real_world_map_state[Key] = Value
	
func get_real_world_map_state(Key: String):
	return real_world_map_state[Key]


# Load the state of the real_world_map.tscn
func load_real_world_map_state() -> Dictionary:
	return real_world_map_state

# Reset game
func reset() -> void:
	opening_played = false
	build_map_state = []
	real_world_map_state = { "shop_played": false, "terminal_played": false}
	knowledge_points = 1500
	current_round = 0 
	score_points = 0
	game_start = false
	reactor_destroyed = false
	level_questions = []
	index = 0
	responses = []
	


## Dialogic relevant functions

func load_all_questions()-> void:
	level_questions = await ApiManager.get_level_questions(current_round)
	
func get_current_round()-> int:
	return current_round
	
func clear_questions()-> void:
	Dialogic.VAR.set_variable("last_question", false)
	level_questions = []
	index = 0

func next_question()-> void:
	if(index >= level_questions.size()):
		Dialogic.VAR.set_variable("question", "default")
		return
	if(index == level_questions.size() - 1):
		Dialogic.VAR.set_variable("last_question", true)
	Dialogic.VAR.set_variable("question", level_questions[index].question)
	index += 1

func review_page() -> void:
	change_scene(REVIEWED_REPORT_SCENE)
	
func get_answer(questionId)-> String:
	answer = await ApiManager.get_answer(questionId)
	if answer == null:
		return "No answer available"
	return str(answer)
	
# response to questions asked
func save_responses() -> void:
	var response = Dialogic.VAR.get_variable("response")
	responses.append(response)

func get_responses() -> Array[String]:
	return responses

func get_questions() -> Array:
	return level_questions

func clear_responses() -> void:
	responses = []
