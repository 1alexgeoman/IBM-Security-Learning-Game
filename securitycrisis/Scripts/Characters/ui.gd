extends CanvasLayer

# instantiate a new Defence
func set_tower_preview(tower_type: String, mouse_position: Vector2) -> void:
	var drag_tower = load("res://Scenes/Maps/Defenses/" + tower_type + ".tscn").instantiate()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = Color("4bff1577")

	var control = Control.new()
	control.add_child(drag_tower)
	control.position = mouse_position
	control.set_name("TowerPreview")
	add_child(control)
	move_child(get_node("TowerPreview"),0)
	
func update_tower_preview(new_position: Vector2, color: Color) -> void:

	get_node("TowerPreview").position = new_position
	if get_node("TowerPreview/DragTower").modulate != Color(color):
		get_node("TowerPreview/DragTower").modulate = Color(color)
