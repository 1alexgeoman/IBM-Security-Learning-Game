extends Area2D

@onready var build_scene: PackedScene = preload("res://Scenes/Maps/build_map.tscn")

@export var SceneTransitionNode: Node2D

var player_inside: bool = false  # Track if the player is in the area
var played: bool = false

func _ready():
	played = GameManager.get_real_world_map_state("terminal_played")

func _on_body_entered(body):
	if body is CharacterBody2D:
		player_inside = true
		change_color(Color(0, 0, 1))  # Change to blue when player enters

func _on_body_exited(body):
	if body is CharacterBody2D:
		player_inside = false
		change_color(Color(1, 1, 1))  # Change back to white when player leaves

func _process(_delta):
	if player_inside and Input.is_action_just_pressed("interact"):  # "E" or "Enter" key
		trigger_event()

func change_color(new_color):
	var sprite: Sprite2D = $Sprite2D
	sprite.modulate = new_color

func trigger_event():
	var animationPlayer = SceneTransitionNode.get_node("AnimationPlayer")
	animationPlayer.play("fade_in")
	await get_tree().create_timer(0.5).timeout
	if GameManager.current_round == 0 and !played:
		played = true
		GameManager.save_real_world_map_state("terminal_played", played)
		Dialogic.start("terminal_timeline")
		
	GameManager.change_to_preloaded_scene(build_scene)
