extends RichTextLabel

func _ready():
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	custom_minimum_size = Vector2(1050, 0)

func escape(bbcode_text):
	return bbcode_text.replace("[", "[lb]")

func set_question_text(idx: int, question: Question, response: String, mark: Question_Marked) -> void:
	var q: Question= question
		
	text += str(idx + 1) + ". " + q.question + "\n"
	text += "Your Ans: [color=%s]" % ("#32CD32" if mark.mark else "#B22222") + escape(response) + "[/color]\n"
	
	if q.type == QUESTION_TYPES.ENUM.MCQ:
		text += "Ans: " + await GameManager.get_answer(q.id) + "\n\n"
	elif q.type == QUESTION_TYPES.ENUM.EssayQ:
		var m: Essay_Marked= mark
		text += "\nFeedback: " + m.feedback

func set_error_question_text(idx: int, question: Question, response: String) -> void:
	var q: Question= question

	text += str(idx + 1) + ". " + q.question + "\n"
	text += "Your Ans (Unable to get mark from server): [color=#FFA500]" + escape(response) + "[/color]\n"

	if q.type == QUESTION_TYPES.ENUM.MCQ:
		text += "Ans: " + await GameManager.get_answer(q.id) + "\n\n"
	elif q.type == QUESTION_TYPES.ENUM.EssayQ:
		text += "\nFeedback: Unavailable (bad response from server)"

func set_all_question_text(questions: Array[Question], responses: Array[String], marks: Array[Question_Marked])->void:
	text = ""
	for q_i in range(0, questions.size()):
		await set_question_text(q_i, questions[q_i], responses[q_i], marks[q_i])
