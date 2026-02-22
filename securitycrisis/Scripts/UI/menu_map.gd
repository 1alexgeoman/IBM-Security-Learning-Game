extends Node2D

var defences: Array[Defence] = [

]

const TILE_SIZE: int= 64
const TILE_OFFSET: Vector2= Vector2(-32,-32)

enum STORAGE_TYPE {
	POSITIONS,
	RANGES
}

# stores the type of enemy and its positions
const screen_defences: Array[Array]= [
	[DEFENCES.ANTI_MALWARE, STORAGE_TYPE.POSITIONS, Vector2(13, 8), Vector2(24,10), Vector2(15,14), Vector2(19,19)],
	[DEFENCES.ANTI_VIRUS, STORAGE_TYPE.POSITIONS, Vector2(24,11), Vector2(22,17)],
	[DEFENCES.TROJAN_BUSTER, STORAGE_TYPE.POSITIONS, Vector2(14,9), Vector2(23,12), Vector2(24,17)],
	[DEFENCES.AI_SPAM_FILTER, STORAGE_TYPE.POSITIONS, Vector2(15, 19), Vector2(24,19)],
	[DEFENCES.ANTI_SQL_INJECTION, STORAGE_TYPE.POSITIONS, Vector2(16, 19)],
	[DEFENCES.FIREWALL, STORAGE_TYPE.RANGES, [12, 27, 7, 7], [12, 12, 7, 23], [22, 26, 21, 21], [26, 26, 16, 21]]
]

var round: int= 5

func spawn_defences():
	for c in $Defences.get_children():
		$Defences.remove_child(c)
		c.queue_free()
		
	for info in screen_defences:
		var type: STORAGE_TYPE= info[1]

		if type == STORAGE_TYPE.POSITIONS:
			for position_i in range(2, info.size()):
				var pos: Vector2= info[position_i]

				var d: Defence= Defence_data.get_defence(info[0]).instantiate()
				d.position= pos * Vector2(TILE_SIZE, TILE_SIZE) + TILE_OFFSET
				
				$Defences.add_child(d)
		elif type == STORAGE_TYPE.RANGES:
			for range_i in range(2, info.size()):
				var range: Array= info[range_i]

				var start_x= range[0]
				var end_x= range[1]
				var start_y= range[2]
				var end_y= range[3]

				while (start_x != end_x || start_y != end_y):
					var d: Defence= Defence_data.get_defence(info[0]).instantiate()
					d.position= Vector2(start_x, start_y) * Vector2(TILE_SIZE, TILE_SIZE) + TILE_OFFSET

					$Defences.add_child(d)

					if (start_x != end_x): start_x += 1 * 1 if start_x < end_x else -1 
					if (start_y != end_y): start_y += 1 * 1 if start_y < end_y else -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CyberGameMap/Reactor.reactor_destroyed.connect(func(): end_game(false))
	
	spawn_defences()
	$EnemySpawner.reset(round)

func end_game(won: bool):
	print("END GAME!")
	if won:
		round += 1
		if round >= 10:
			round= 5
	else:
		spawn_defences()
		round= 5

	for e in get_tree().get_nodes_in_group("Enemies"):
		e.queue_free()

	$CyberGameMap/Reactor.reset_health()
	$EnemySpawner.reset(round)
