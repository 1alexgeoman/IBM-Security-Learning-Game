extends Defence
class_name Turret

# The count of turrets that can be deployed

var closest_enemy: Enemy = null;
# once we find an enemy we lock onto them for 1 second minimum
const CLOSEST_ENEMY_LOCKON_MIN: float = 1.0;
var closest_enemy_lockon_timer: float = 0;

## The speed at which the turret can rotate
@export var turret_rotation_speed: float = 2;
var target_rotation: float = 0;

@export var projectile_scene: PackedScene;
var fire_delta_max: float = 1
const MAX_ROTATION_DIFF_TO_FIRE: float = 0.1;
var fire_delta: float = 0;

const CREATED_PROJ_SPEED: int = 500
var damage_multiplier: float = 1.0  # default damage multiplier
@export var turret_type: String = "GENERIC"

func _ready():
	apply_damage_boost()
	apply_fire_rate_upgrade()

	var deletion_timer = Timer.new()
	deletion_timer.wait_time = 0.5
	deletion_timer.one_shot = true
	deletion_timer.connect("timeout", Callable(self, "enable_deletion"))
	add_child(deletion_timer)
	deletion_timer.start()

func process(delta: float) -> void:
	if is_disabled:
		return

	closest_enemy_lockon_timer += delta
	fire_delta += delta

	update_rotation(delta)

	if (fire_delta >= fire_delta_max):
		# attempt_fire_projectile updates the fire_delta IF it fires
		attempt_fire_projectile()

func apply_fire_rate_upgrade():
	fire_delta_max = fire_delta_max * DefenseManager.global_fire_rate_multiplier

func apply_damage_boost():
	damage_multiplier = DefenseManager.global_damage_multiplier

func reset_damage_boost():
	damage_multiplier = 1.0

func update():
	update_closest_enemy()
	update_target_rotation()

func update_closest_enemy():
	if (closest_enemy != null && is_instance_valid(closest_enemy)):
		var updated_closest = get_closest_enemy()

		# if there exists a closer enemy that is different and we have locked onto the current for the min time then we can change the enemy
		if (updated_closest != null && closest_enemy != updated_closest && closest_enemy_lockon_timer >= CLOSEST_ENEMY_LOCKON_MIN):
			closest_enemy_lockon_timer = 0
			closest_enemy = updated_closest
	else:
		closest_enemy_lockon_timer = 0;
		closest_enemy = get_closest_enemy()

func lead_target_position(enemy: Enemy):
	if (enemy == null): return null;
	if (CREATED_PROJ_SPEED < enemy.vel.length()): return null;

	# currently just the enemies velocity as the turret is stationary -- could be - vel
	var vel_delta: Vector2 = enemy.vel
	var pos_delta: Vector2 = enemy.global_position - global_position
	# quadratic formula a, b, and c values
	var a: float = vel_delta.dot(vel_delta) - CREATED_PROJ_SPEED * CREATED_PROJ_SPEED
	var b: float = 2 * vel_delta.dot(pos_delta)
	var c: float = pos_delta.dot(pos_delta)

	var det: float = b*b - 4 * a * c

	if (det < 0):
		return null
	
	var t: float = 2 * c / (sqrt(det) - b)

	if (t < 0):
		return null

	return enemy.position + t * vel_delta
	
func update_target_rotation():
	var target_position;

	var lead_position = lead_target_position(closest_enemy)
	if (lead_position == null):
		# todo change to default rotation state
		target_position = Vector2(0,0)
	else:
		target_position = lead_position

	# this is just the angle from the non rotated Node ot the enemy
	var base_angle: float = global_position.angle_to_point(target_position)
	target_rotation = wrapf(base_angle, -PI, PI)

func update_rotation(delta: float):
	var turret_node = $Turret

	var rotation_diff = wrapf(target_rotation - turret_node.rotation, -PI, PI)
	# the max frame rotation is based on the delta for the frame and the turret's rotation speed
	var MAX_FRAME_ROTATION_STEP = delta * turret_rotation_speed
	var rotation_step: float = clamp(rotation_diff, -MAX_FRAME_ROTATION_STEP, MAX_FRAME_ROTATION_STEP)

	turret_node.rotation += rotation_step
	# wrap to ensure that comparing distances is accurate
	turret_node.rotation = wrapf(turret_node.rotation, -PI, PI)

func is_enemy_match(enemy: Enemy) -> bool:
	return false

func dist_match_weighted_cmp(enemyA: Enemy, enemyB: Enemy) -> bool:
	var aDist: float= enemyA.global_position.distance_squared_to(global_position)
	var bDist: float= enemyB.global_position.distance_squared_to(global_position)

	if !is_enemy_match(enemyA):
		aDist *= 5
	if !is_enemy_match(enemyB):
		bDist *= 5

	return aDist < bDist

func dist_cmp(enemyA: Area2D, enemyB: Area2D) -> bool:
	return enemyA.position.distance_squared_to(position) < enemyB.position.distance_squared_to(position)

func get_closest_enemy() -> Enemy:
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var visible_enemies: Array = []

	# Just hard code, to implement that the trojan enemies can't be attacked if not be detected
	for enemy  in enemies:
		if enemy.enemy_type == "TROJAN":
			var mod = enemy.modulate
			if abs(mod.r - 0.3) < 0.01 and abs(mod.g - 0.3) < 0.01 and abs(mod.b - 0.3) < 0.01:
				continue
		visible_enemies.append(enemy)

	visible_enemies.sort_custom(dist_cmp)

	if visible_enemies.is_empty():
		return null
	
	return visible_enemies[0]
	


func create_projectile(spawn_point: Marker2D) -> Projectile:
	var turret_node = $Turret
	var turret_rot = turret_node.rotation

	var proj = projectile_scene.instantiate()
	# convert the turrets rotation into a direction
	var proj_dir: Vector2 = Vector2(cos(turret_rot), sin(turret_rot)).normalized()
	var proj_speed: int = CREATED_PROJ_SPEED

	proj.create(spawn_point.global_position, proj_dir * proj_speed, damage_multiplier, turret_type)

	return proj

func fire() -> void:
	add_child(create_projectile($Turret/Muzzle))

func attempt_fire_projectile() -> void:
	if closest_enemy == null:
		return

	if abs(target_rotation - $Turret.rotation) > MAX_ROTATION_DIFF_TO_FIRE:
		return

	fire_delta = 0
	fire()

func damage(health_loss: int) -> void:
	update_health(health_loss)

	defence_damaged.emit(health_loss)

	if ($healthBar.value <= 0):
		defence_destroyed.emit()
		hide()
		queue_free()
		
func update_health(change: int) -> void:

	$healthBar.value -= change
