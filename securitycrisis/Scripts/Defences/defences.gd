extends Node2D

## Code contains code from previous "Game.tscn" and build_map.tscn

@export var enemy_scene: PackedScene

var build_mode = false
var build_valid = false
var build_location
var build_type
var saved_defences = []
var placed_defences = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	saved_defences = GameManager.load_build_map_state()
	load_defenses()

	# clear after defenses have been loaded
	saved_defences = []
	for button in get_tree().get_nodes_in_group("build_buttons"):
		button.pressed.connect(initiate_build_mode.bind(button.name))


# Calls update_tower_preview whenever build_mode is true
func _process(_delta: float) -> void:
	if build_mode:
		update_tower_preview()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel") and build_mode == true:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode == true:
		verify_and_build()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed == false:
			var global_mouse_pos = get_global_mouse_position()
			remove_defense(global_mouse_pos)
		

# calls set_tower_preview
func initiate_build_mode(tower_type: String) -> void:
	build_type = tower_type
	build_mode = true
	%UI.set_tower_preview(build_type,get_global_mouse_position())

func snap_centre32(pos: Vector2, size: Vector2) -> Vector2:
	return (pos - (size / 2)).snapped(Vector2(32,32)) + (size / 2)

func update_tower_preview():
	var defence_local_mouse_pos = get_local_mouse_position()
	var defence_snapped = snap_centre32(defence_local_mouse_pos, Vector2(64,64))

	var global_mouse_pos = to_global(defence_snapped)

	var boundary_layer = %CyberGameMap/BoundaryLayer
	var boundary_local_mouse_pos = boundary_layer.to_local(global_mouse_pos)

	var boundry_map_tile = boundary_layer.local_to_map(boundary_local_mouse_pos)

	var viewport_position = get_global_transform_with_canvas() * global_mouse_pos

	if boundary_layer.get_cell_tile_data(boundry_map_tile) == null:
		#position is valid
		%UI.update_tower_preview(viewport_position,"4bff1577")
		build_valid = true
		build_location = global_mouse_pos
	else:
		#position is invalid
		%UI.update_tower_preview(viewport_position, "ff030b77")
		build_valid = false


func cancel_build_mode():
	build_mode = false
	build_valid = false
	%UI.get_node("TowerPreview").queue_free()

func verify_and_build():
	if build_valid:
		if DefenseManager.get_deploy_count(build_type) > 0:
			var new_tower = load("res://Scenes/objects/Defenses/" + build_type + ".tscn").instantiate()
			new_tower.global_position = build_location
			add_child(new_tower)
			placed_defences.append(new_tower)
			
			DefenseManager.modify_deploy_count(build_type, -1)
			
			%UI.update_deploy_count(build_type, DefenseManager.get_deploy_count(build_type))
		
		cancel_build_mode()

func save_defences():
	for child in get_children():
		if child.is_in_group("Defences"):
			var defence_data = {
				"position": child.position,
				"path": child.scene_file_path
				# add other properties if needed
			}
			saved_defences.append(defence_data)
	GameManager.save_build_map_state(saved_defences)

func load_defenses():
	for defence_data in saved_defences:
		var new_defence = load(defence_data["path"]).instantiate()
		# Set properties from the saved data
		new_defence.position = defence_data["position"]
			#new_defense.some_custom_property = defense_data["other_property"]

		# Add the new Area2D to the scene
		add_child(new_defence)
		placed_defences.append(new_defence)

func remove_defense(mouse_position: Vector2) -> void:
	for defense in placed_defences:
		if defense.global_position.distance_to(mouse_position) < 32:
			defense.queue_free()
			placed_defences.erase(defense)
			
			Dialogic.start("defense_removed_timeline")
			
			var defense_type = defense.name
			DefenseManager.modify_deploy_count(defense_type, 1)
			
			%UI.update_deploy_count(defense_type, DefenseManager.get_deploy_count(defense_type))
			
			break
