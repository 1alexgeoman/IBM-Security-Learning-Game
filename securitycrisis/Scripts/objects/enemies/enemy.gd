extends Area2D
class_name Enemy

@export var enemy_speed: int = 150
@export var shouldFaceMoveDirection: bool = true

signal hit

# from 1 - 2, 2 means everything takes twice as long
var slow_down: float= 1;

var update_delta_max: float = 0.1;
var update_delta: float = 0;

var MAX_HEALTH: int = 100;
var health: int = MAX_HEALTH;

# todo: find a nicer way to store this information, each enemy type may do different damage to each defence type?
var damage2Turret: int = 10

# how close the enemy should be to the reactor to where it will not try and attack anything else
var reactor_distance_threshold = 300
# how close to a defence an enemy should be to attack instead of attacking the reactor
var defence_distance_threshold = 250
# how close to a player an enemy should be to attack instead of attacking the reactor (precedence over defences)
var player_distance_threshold = 150

# How close the enemy should get up to an attackable before it attacks
const ENEMY_REACH_DIST_SQRD: int = 50 * 50;

# The enemies current velocity, this is used by the defences to aim; so make sure it is updated!
var vel: Vector2 = Vector2(100, 0)

# Can attack every 2 seconds
var ATTACK_COOLDOWN_MAX = 2
var attack_cooldown = 0

@export var effect_factor: float = 1.0
@export var effect_duration: float = 5.0
@export var follow_mouse: bool = false

@export var enemy_type: String = "GENERIC"

func _ready() -> void:
	update_health(0)

func dist_cmp(defA: Area2D, defB: Area2D) -> bool:
	return defA.position.distance_squared_to(position) < defB.position.distance_squared_to(position)

func get_reactor() -> Reactor:
	return get_tree().get_nodes_in_group("Reactor")[0]

func get_player() -> CyberPlayer:
	var players = get_tree().get_nodes_in_group("Player")
	if players.is_empty():
		return null
	return get_tree().get_nodes_in_group("Player")[0]

func clamp_movement(direction: Vector2, delta: float, target: Vector2) -> Vector2:
	var speed: float = enemy_speed

	vel= direction * speed
	var new_position = position + direction * speed * delta

	var minx= min(position.x, target.x)
	var maxx= max(position.x, target.x)
	var miny= min(position.y, target.y)
	var maxy= max(position.y, target.y)

	return Vector2(clamp(new_position.x, minx, maxx), clamp(new_position.y, miny, maxy))

func norm_direction_to(to_position: Vector2) -> Vector2:
	return (to_position - position).normalized()

func move_towards(to_position: Vector2, delta: float) -> void:
	var direction_norm = norm_direction_to(to_position)

	position= clamp_movement(direction_norm, delta, to_position)

func face_direction(direction_norm: Vector2) -> void:
	rotation = direction_norm.angle()

func move_towards_and_face(to_position: Vector2, delta: float) -> void:
	var direction_norm = norm_direction_to(to_position)
	face_direction(direction_norm)

	position= clamp_movement(direction_norm, delta, to_position)

func nearest_point_on_circle(cx, cy, cr) -> Vector2:
	var theta = atan2((position.y - cy), (position.x - cx))
	var nx= cx + cr * cos(theta)
	var ny= cy + cr * sin(theta)

	return Vector2(nx, ny)

func nearest_point_on_rect(rx, ry, rw, rh) -> Vector2:
	return Vector2(clamp(position.x, rx, rx+rw), clamp(position.y, ry, ry+rh))

func nearest_point_on_capsule(cx, cy, ch, cr) -> Vector2:
	var cap_non_r: int = ch - 2 * cr

	var nx = 0
	var ny = 0

	var closest_point

	if position.y >= cy - cap_non_r / 2 && position.y <= cy + cap_non_r / 2:
		ny = position.y
		var left = position.x < cx
		if left:
			nx = cx - cr
		else:
			nx = cx + cr

		closest_point = Vector2(nx, ny)
	else:
		var top = position.y <= cy
		if top:
			closest_point = nearest_point_on_circle(cx, cy - cap_non_r / 2, cr)
		else:
			closest_point = nearest_point_on_circle(cx, cy + cap_non_r / 2, cr)

	return closest_point
	

# if we have reached the destination return true
func move_toward_nearest_point_on(area: Node2D, delta: float) -> bool:
	var shape: CollisionShape2D
	if area is Defence:
		shape= area.get_enemy_attack_shape()
	else:
		shape= area.get_node("CollisionShape2D")
	var closest_point = area.global_position
	var pos = shape.global_position

	if shape.shape is CircleShape2D:
		var circle: CircleShape2D = shape.shape
		closest_point = nearest_point_on_circle(pos.x, pos.y, circle.radius)
	if shape.shape is CapsuleShape2D:
		var cap: CapsuleShape2D = shape.shape
		closest_point = nearest_point_on_capsule(pos.x, pos.y, cap.height, cap.radius)
	if shape.shape is RectangleShape2D:
		var rect: RectangleShape2D = shape.shape
		closest_point = nearest_point_on_rect(pos.x, pos.y, rect.size[0], rect.size[1])

	var direction = norm_direction_to(closest_point)
	if shouldFaceMoveDirection:
		face_direction(direction)

	var reached_dest = closest_point.distance_squared_to(position) <= ENEMY_REACH_DIST_SQRD
	if reached_dest:
		vel = Vector2(0,0)
	else:
		position= clamp_movement(direction, delta, closest_point)

	return reached_dest

# even without targetting of the reactor this will default to it when there are no other targets
func get_attack_area_(defences_attackable: bool, reactor_attackable: bool, player_attackable: bool):
	if (!defences_attackable && !reactor_attackable && !player_attackable):
		printerr("Cannot attack no targets")
		return

	var defences = get_tree().get_nodes_in_group("Defences").filter(func(def): return def.targetable_defence)
	var has_defences= !defences.is_empty();

	var reactor = get_reactor()
	if (reactor_attackable):
		var reactor_dist = reactor.global_position.distance_to(global_position)

		if reactor_dist <= reactor_distance_threshold && reactor_attackable:
			return reactor

	if (player_attackable):
		var player = get_player()
		if player != null and player.is_alive():
			var player_dist = player.global_position.distance_to(global_position)

			if player_dist <= player_distance_threshold:
				return player

	if has_defences && defences_attackable:
		defences.sort_custom(dist_cmp)
		var closest_defense = defences[0]
		var closest_defence_dist = closest_defense.global_position.distance_to(global_position)

		if closest_defence_dist <= defence_distance_threshold:
			return closest_defense

	return reactor

func get_attack_area():
	return get_attack_area_(true, true, true)

# the delta passed to this should be the effective delta i.e. any effects that affect the speed should change the delta passed in
func process_actions(delta: float) -> void:
	attack_cooldown += delta

	var attack_area = get_attack_area()
	var at_attack_point = move_toward_nearest_point_on(attack_area, delta)

	if at_attack_point:
		attempt_attack(attack_area)

func process_state(delta: float) -> void:
	pass

func _process(delta: float) -> void:
	process_actions(delta / slow_down)

func face_defense(defense_position: Vector2) -> void:
	var direction = (defense_position - position).normalized()
	#print("Facing direction: ", direction)

	rotation = direction.angle()

func get_center() -> Vector2:
	var shape: RectangleShape2D = $CollisionShape2D.shape
	var center: Vector2 = global_position + (shape.size / 2)
	return center

func attempt_attack(target) -> void:
	if attack_cooldown >= ATTACK_COOLDOWN_MAX:
		attack_cooldown = 0
	else:
		return

	target.damage(damage2Turret)

func damage(damage_type, health_loss: int) -> void:
	if (damage_type == DAMAGE_TYPES.ANTI_VIRUS):
		update_health(-(health_loss<<1))
	else:
		update_health(-health_loss)

	if (health <= 0):
		hide()
		queue_free()

func update_health(change: int) -> void:
	health += change

	$HealthBar.value = (health as float / MAX_HEALTH) * 100

func _on_area_entered(area:Area2D) -> void:
	if (area.is_in_group("Projectiles")):
		var projectile: Projectile = area
		var turret_type = projectile.source_turret_type
		var base_damage = projectile.damage
		var damage_multiplier = 1.0

		if turret_type != enemy_type:
			damage_multiplier = 0.25

		var total_damage = base_damage * damage_multiplier
		damage(projectile.damage_type, total_damage)
		hit.emit()
		
func set_slowdown_effect(amount: float) -> void:
	slow_down= amount

func remove_slowdown_effect() -> void:
	slow_down= 1
