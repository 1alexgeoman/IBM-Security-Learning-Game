extends CanvasLayer

var defense_icons = {}  # store the relevant defense name 

func _ready():
	for button in $HUD/BuildBar.get_children():
		var label_node = button.get_node("Label")
		if label_node:
			defense_icons[button.name] = label_node  # binds the button with label

		update_count_display(button.name, DefenseManager.get_deploy_count(button.name))

# update the count display
func update_count_display(defense_type: String, count: int):
	if defense_icons.has(defense_type):
		defense_icons[defense_type].text = str(count)

# update the count of turrets that can be deployed
func update_deploy_count(defense_type: String, count: int):
	update_count_display(defense_type, count)

# instantiate a new Defence
func set_tower_preview(tower_type: String, mouse_position: Vector2) -> void:
	var drag_tower = load("res://Scenes/objects/Defenses/" + tower_type + ".tscn").instantiate()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = Color("4bff1577")

	var control = Control.new()
	control.add_child(drag_tower)
	control.global_position = mouse_position
	control.set_name("TowerPreview")
	add_child(control)
	move_child(control,0)

func update_tower_preview(new_position: Vector2, color: Color) -> void:
	if !get_node_or_null("TowerPreview") || !get_node_or_null("TowerPreview/DragTower"):
		return

	$TowerPreview.global_position = new_position
	$TowerPreview/DragTower.modulate = Color(color)
