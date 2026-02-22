extends Control

var queue: Array[String]= []

@onready var done_button: Button= $Button
@onready var label: Label= $Label

func _ready() -> void:
	visible= false
func next() -> void:
	if queue.is_empty():
		visible= false
		return
	label.text= queue.pop_front()
	visible= true

func try_hint(hint: String) -> void:
	queue.push_back(hint)
	if visible:
		return
	
	next()

func _on_button_pressed() -> void:
	next()

func add_hint(hint: String) -> void:
	try_hint(hint)
