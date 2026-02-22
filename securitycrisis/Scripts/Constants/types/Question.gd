extends Resource

class_name Question

var id      : int;
var question: String;
var text    : String;
var type    : QUESTION_TYPES.ENUM;

func _init(_id: int, _question: String, _text: String, _type: QUESTION_TYPES.ENUM):
	id       = _id
	question = _question
	text     = _text
	type     = _type
