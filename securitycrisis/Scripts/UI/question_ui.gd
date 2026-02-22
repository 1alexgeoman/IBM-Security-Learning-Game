extends Control
	
@onready var question_label = $QuestionLabel
@onready var answer_input = $AnswerInput
@onready var choices_container = $ChoicesContainer
@onready var submit_button = $SubmitButton
@onready var feedback_label = $FeedbackLabel

var current_question = null

func _ready():
	QuestionManager.question_answered.connect(_on_question_answered) 
	load_new_question()

# Achieve new questions
func load_new_question():
	current_question = QuestionManager.get_random_question()

	question_label.text = current_question.question

	if current_question.has("choices"):
		answer_input.hide() 
		choices_container.show()
		display_choices(current_question.choices)
	else:
		choices_container.hide()
		answer_input.show()
		answer_input.text = ""  

# Display the choices
func display_choices(choices):
	for child in choices_container.get_children():
		choices_container.remove_child(child)
		child.queue_free()

	for choice in choices:
		var button = Button.new()
		button.text = choice
		button.pressed.connect(func(): _on_choice_selected(choice))
		choices_container.add_child(button)

func _on_submit_button_pressed() -> void:
	var player_answer = answer_input.text.strip_edges()
	QuestionManager.check_answer(player_answer) 
	
func _on_choice_selected(choice):
	QuestionManager.check_answer(choice)
	
func _on_question_answered(correct, correct_answer):
	if correct:
		feedback_label.text = "Correct! +50 KP. Current Currency is %d" % GameManager.knowledge_points
	else:
		feedback_label.text = "Wrong! Correct answer: " + correct_answer

	feedback_label.show()
	await get_tree().create_timer(2).timeout 
	feedback_label.hide()
	load_new_question()  
