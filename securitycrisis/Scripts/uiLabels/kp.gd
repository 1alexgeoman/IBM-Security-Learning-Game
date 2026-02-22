extends Label

@onready var kp:int

func set_kp_label()->void:
	kp = GameManager.get_kp()
	text = "Current total KP: %d" % kp
