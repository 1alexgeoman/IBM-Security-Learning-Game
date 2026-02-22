extends Question_Marked

class_name Essay_Marked

var distance: float
var sample: Array
var feedback: String

func _init(_type: QUESTION_TYPES.ENUM, _mark: int, _kp: int, _distance: float, _sample: Array, _feedback: String) -> void:
	super._init(_type, _mark, _kp)

	distance= _distance
	sample  = _sample
	feedback= _feedback
