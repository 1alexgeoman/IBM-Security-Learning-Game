extends Node2D

@onready var enemy = preload("res://Scenes/objects/Enemies/Enemy.tscn")
@onready var rand = RandomNumberGenerator.new()

func _on_timer_timeout() -> void:
	add_child(create_enemy())

func create_enemy() -> Node:
	var e = enemy.instantiate()

	var mob_spawn_location = $SpawnPath/SpawnLocation
	mob_spawn_location.progress_ratio = rand.randf()

	e.position = mob_spawn_location.position

	return e
