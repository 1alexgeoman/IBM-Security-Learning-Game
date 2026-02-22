extends NPC

@onready var player: CharacterBody2D = $"../Player"
@onready var back_button = "BackGround/MainVBox/HBoxContainer/BackButton"

var played_info: bool= false
var connected: bool= false

func _ready() -> void:
	super._ready()

	played_info= GameManager.get_real_world_map_state("shop_played")
	

func has_dialog() -> bool:
	return not played_info

func interact_event() -> void:
	%ShopUI.visible = true
	if !connected:
		%ShopUI.get_node(back_button).pressed.connect(exit_event)
		connected = true
	
	
	if !played_info: 
		Dialogic.start("ninaTimeline0")
		played_info= true

		GameManager.save_real_world_map_state("shop_played", true)
		
	get_parent().visible = false
	player.disable_movement = true  # Disable movement

func exit_event() -> void:
	%ShopUI.visible = false
	get_parent().visible = true
	player.disable_movement = false  # Re-enable movement
