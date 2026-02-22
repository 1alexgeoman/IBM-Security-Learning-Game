extends CharacterBody2D
@onready var anima_tree=$AnimationTree


enum {
	WALK
}

var state = WALK
const SPEED = 300.0
var disable_movement: bool = false


func _ready() -> void:
	Dialogic.timeline_started.connect(movement)
	Dialogic.timeline_ended.connect(movement)
	

func _physics_process(_delta):
	match state:
		WALK:
			walk_state()

	move_and_slide()	
func walk_state():
	if disable_movement:
		anima_tree["parameters/playback"].travel("Idle")
		velocity= Vector2.ZERO
		return  # Exit function to prevent input processing
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	if direction:
		anima_tree.set("parameters/Idle/blend_position",direction)
		anima_tree.set("parameters/Walk/blend_position",direction)
		anima_tree["parameters/playback"].travel("Walk")
		velocity = direction * SPEED
	else:
		anima_tree["parameters/playback"].travel("Idle")
		velocity= Vector2.ZERO

func movement():
	disable_movement = !disable_movement
