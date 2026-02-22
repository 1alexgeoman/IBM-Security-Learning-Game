extends Node

signal question_answered(correct: bool) # trigger the signal to represent the question answered 

var questions = [
	{"question": "What is 2 + 2?", "answer": "4"},
	{"question": "What is the capital of France?", "answer": "Paris"},
	{"question": "Which protocol is used for secure web browsing?", "answer": "HTTPS"}
]

var current_question = null

func get_random_question():
	#current_round starts from 0, not sure where this function belongs to for now I will comment it out - Korede
	#return await get_question(GameManager.current_round + 1)
	current_question = questions[randi() % questions.size()]  # choose questions randomly
	return current_question

func check_answer(player_answer: String):
	if current_question and player_answer.to_lower() == current_question.answer.to_lower():
		print("Correct Answer!")
		question_answered.emit(true,current_question["answer"])
	else:
		print("Wrong Answer!")
		question_answered.emit(false,current_question["answer"])
