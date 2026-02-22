extends Panel

# Node references for the two sides and animation
@onready var front_side = $FrontSide/VBoxContainer   # Front side container (shows item name, cost, purchase button, etc.)
@onready var back_side = $BackSide/VBoxContainer         # Back side container (should contain ContextLabel for full description)
@onready var anim_player = $AnimPlayer
@onready var purchase_button = $FrontSide/VBoxContainer/PurchaseButton
@onready var icon_node = $FrontSide/VBoxContainer/Icon   # TextureRect for the icon
#@onready var lock_overlay = $LockOverlay

var is_flipped: bool = false

func _ready() -> void:
	# Ensure initial state: front side is visible, back side is hidden.
	#lock_overlay.visible = false
	front_side.visible = true
	back_side.visible = false
	# Optionally, adjust the icon node's properties if images are too large:
	if icon_node:
		# Example: Force the icon to a fixed size (adjust as needed)
		icon_node.custom_minimum_size = Vector2(170, 72)
		icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_node.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:  # Use event.pressed (lowercase)
		# If the click is outside of the purchase button, trigger the flip.
		if not purchase_button.get_global_rect().has_point(event.global_position):
			_on_card_pressed()

func _on_card_pressed() -> void:
	if anim_player.is_playing():
		return  # Prevent multiple flips
	
	if is_flipped:
		anim_player.play_backwards("flip")  # Play the existing animation in reverse
	else:
		anim_player.play("flip")
	
	is_flipped = !is_flipped



# This function should be called by the AnimationPlayer's Call Method Track at the flip's midpoint.
func _toggle_sides() -> void:
	front_side.visible = not front_side.visible
	back_side.visible = not back_side.visible
