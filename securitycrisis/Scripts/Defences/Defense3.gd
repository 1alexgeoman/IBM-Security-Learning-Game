extends Defence

@onready var color_rect = $DetectRange/ColorRect
@onready var detect_area = $DetectRange/Detect
@onready var detect_range = $DetectRange

var shader_material

func _ready() -> void:
	shader_material = color_rect.material  
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func process(delta: float) -> void:
	if is_disabled:
		shader_material.set_shader_parameter("blink_state", 0)
		detect_area.set_deferred("monitoring", false)
		return  

	shader_material.set_shader_parameter("blink_state", 1)
	detect_area.set_deferred("monitoring", 1)
	speed_up_nearby_defences()
	
func get_enemy_attack_shape() -> CollisionShape2D:
	return get_node("Damage")
			
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		var enemy: Enemy = area
		#if enemy is SQLInjectionEnemy:
			#disable_defence(enemy.effect_duration)
			
func speed_up_nearby_defences():
	for area in detect_range.get_overlapping_areas():
		if area != self and area is Defence:
			var other_def = area as Defence
			if other_def.is_disabled and !other_def.has_been_sped_up:
				reduce_disable_timer(other_def)
				
func reduce_disable_timer(other_def: Defence):
	other_def.disable_timer *= 0.3
	other_def.has_been_sped_up = true
