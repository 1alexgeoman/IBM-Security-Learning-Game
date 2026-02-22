extends Defence

@onready var color_rect = $DetectRange/ColorRect
@onready var detect_area = $DetectRange/Detect

var shader_material
var blink_timer = 0.0  

func _ready() -> void:
	shader_material = color_rect.material  
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func process(delta) -> void:
	if is_disabled:
		shader_material.set_shader_parameter("blink_state", 0)
		detect_area.set_deferred("monitoring", false)
		return 
	
	blink_timer += delta  

	var blink_state = int(fmod(blink_timer, 2.0) >= 1.2)
	shader_material.set_shader_parameter("blink_state", blink_state)
	detect_area.set_deferred("monitoring", blink_state == 1)	
	
func get_enemy_attack_shape() -> CollisionShape2D:
	return get_node("Damage")

func _on_detect_range_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		var enemy = area
		if enemy is TrojanEnemy:
			highlight_enemy(enemy)
			
func highlight_enemy(enemy: Area2D):
		enemy.modulate = Color(1, 1, 0) 
		
