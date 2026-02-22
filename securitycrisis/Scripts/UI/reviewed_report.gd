extends Control

# Access to all dynamic labels
@onready var enemy_label = $TextureRect/ScrollContainer/MarginContainer/VBoxContainer/Description/EnemyType 
@onready var date_label = $TextureRect/ScrollContainer/MarginContainer/VBoxContainer/Description/Date
@onready var question_label = $TextureRect/ScrollContainer/MarginContainer/VBoxContainer/ActionTaken/HBoxContainer/QuestionLabel
@onready var score_label = $TextureRect/ScrollContainer/MarginContainer/VBoxContainer/VBoxContainer/ScoreLabel

var marked_questions: Array[Question_Marked]
var questions: Array[Question]
var user_answers: Array[String]

var total_kp_earned: int= 800

# to use place holder comment out user_answers= in _ready ~line 28 and the user_answers var above
# var user_answers: Array[String] = ["dwad", "Botnets are harder to detect due to distributed nature","IP Spoofing","Unexpected server downtime","n/a"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	total_kp_earned= 800

	%TextureButton.pressed.connect(done)

	# Change the wave name
	enemy_label.set_level_title(int(GameManager.get_current_round()))
	date_label.set_date()

	await GameManager.load_all_questions()
	questions= GameManager.get_questions()
	user_answers= GameManager.get_responses()

	await mark_questions()

	# await question_label.set_all_question_text(questions, user_answers, marked_questions)
	score_label.set_question_text(marked_questions, total_kp_earned)

func mark_questions() -> bool:
	marked_questions.clear()

	for q_i in range(questions.size()):
		var q: Question= questions[q_i]
		var r: String= user_answers[q_i]

		var m_res: Dictionary= await ApiManager.mark_question(q.id, r)

		if (!m_res.success):
			question_label.set_error_question_text(q_i, q, r)
			continue

		total_kp_earned += m_res.question.kp if m_res.question.mark else 0

		marked_questions.append(m_res.question)

		await question_label.set_question_text(q_i, q, r, m_res.question)

	return true
	
func done() -> void:
	GameManager.add_knowledge_points(total_kp_earned)
	GameManager.clear_questions()
	GameManager.clear_responses()
	GameManager.current_round += 1
	if GameManager.current_round >= 5:
		GameManager.change_scene(GameManager.THANK_YOU)
		return
	GameManager.change_scene(GameManager.REAL_WORLD_MAP_SCENE)
