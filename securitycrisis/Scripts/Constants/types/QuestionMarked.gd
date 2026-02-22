extends Resource

class_name Question_Marked

var type: QUESTION_TYPES.ENUM;
var mark: int
var kp: int

func _init(_type: QUESTION_TYPES.ENUM, _mark: int, _kp: int):
	type= _type
	mark= _mark
	kp  = _kp

func _to_string() -> String:
	return (
"Type: %s
  mark: %d
  kp: %d
" % [type, mark, kp])
