extends Label

func _ready():
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	custom_minimum_size = Vector2(1050, 0)

func set_question_text(marks: Array[Question_Marked], kp: int) -> void:
	var score = 0

	for m in marks:
		score += m.mark

	text = "Review:\nActions Taken: Got " + str(score) + "/" + str(marks.size()) + " correct.\n"
	text += "Total KP Earned: " + str(kp)
	
