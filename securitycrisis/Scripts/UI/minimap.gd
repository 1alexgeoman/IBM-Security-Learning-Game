extends Control

@export var game_map: Node2D
@export var player: CyberPlayer

@onready var boundry_layer: TileMapLayer= game_map.get_node("BoundryLayer")
@onready var reactor: Reactor= game_map.get_node("Reactor")

const dims: Vector2 = Vector2(1920/8,1080/8)
var dims_scale: float = 0
var top_bottom_offset: float = 0

var map_dims: Vector2
var tile_size: Vector2
var map_scale: Vector2

func calculate_map_size() -> Vector2:
	return game_map.									\
		get_children().									\
		filter(func(c): return c is TileMapLayer).		\
		reduce(max, Vector2(0,0))

func _ready() -> void:
	var outer_layer: TileMapLayer = game_map.get_node("OuterLayer")
	tile_size = Vector2(outer_layer.tile_set.tile_size) 
	var outer_size: Vector2= Vector2(outer_layer.get_used_rect().size) * tile_size

	map_scale= outer_layer.transform.get_scale()
	map_dims= outer_size * map_scale

func draw_reactor() -> void:
	var reactor_loc: Vector2= reactor.global_position / map_dims

	var scaled = reactor_loc * dims

	draw_circle(scaled, 4, Color.BLACK)

func draw_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		var enemy_loc: Vector2 = enemy.global_position / map_dims

		var scaled = enemy_loc * dims

		draw_circle(scaled, 2, Color.RED)

func draw_player() -> void:
	var player_loc: Vector2= player.global_position / map_dims

	var scaled = player_loc * dims

	draw_circle(scaled, 2, Color.GREEN)

func draw_defences() -> void:
	var defences = get_tree().get_nodes_in_group("Defences")
	for defence in defences:
		var defence_loc: Vector2 = defence.global_position / map_dims

		var scaled = defence_loc * dims

		draw_circle(scaled, 2, Color.CYAN)

func draw_background() -> void:
	var rect: Rect2 = Rect2(Vector2(0,0), dims)
	draw_rect(rect, Color.GRAY)

func draw_tile_data(data: Array[Vector2i], color: Color):
	for tiledata: Vector2i in data:
		var start_pos: Vector2 = (Vector2(tiledata) * tile_size * map_scale)
		var end_pos: Vector2 = (start_pos + tile_size * map_scale)

		var screen_pos = (start_pos / map_dims) * dims
		var screen_end_pos = (end_pos / map_dims) * dims

		var rect: Rect2 = Rect2(screen_pos, screen_end_pos - screen_pos)
		draw_rect(rect, color)

func draw_boundry() -> void:
	draw_tile_data(game_map.get_node("BoundaryLayer").get_used_cells(), Color.BLACK)
	draw_tile_data(game_map.get_node("OuterLayer").get_used_cells(), Color.BLACK)
	# draw_tile_data(game_map.get_node("ToxicWasteLayer").get_used_cells(), Color.PURPLE)

func update_minimap() -> void:
	draw_background()
	draw_boundry()
	
	draw_reactor()
	draw_enemies()
	draw_player()
	draw_defences()

func _draw() -> void:
	update_minimap()

func _process(_delta):
	queue_redraw()
