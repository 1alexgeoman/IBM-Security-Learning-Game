extends Node2D

var ended: bool = false

func _ready() -> void:
	
	$CyberGameMap/Reactor.reactor_destroyed.connect(func():
		if !ended:
			end_game(false)
			ended = true
	)

	$UI/RespawnHud.visible = false
	$UI/WaveHud.visible = true

	$EnemySpawner.next_round()

	$Defences.load_defenses()

	await get_tree().process_frame
	var remote_transform = $CyberWorldPlayer/RemoteTransform2D
	if remote_transform:
		%Camera2D.zoom = Vector2(2, 2) 
		remote_transform.remote_path = %Camera2D.get_path()  # Use relative path to reference sibling
	else:
		printerr("Error: RemoteTransform2D node not found in player")

func _on_cyber_world_player_player_died() -> void:
	$UI/RespawnHud.visible = true

	$CyberWorldPlayer.visible = false
	$CyberWorldPlayer.set_process(false)

	$RespawnTimer.start()

func _on_respawn_timer_timeout() -> void:
	$UI/RespawnHud.visible = false

	$CyberWorldPlayer.global_position = $RespawnLocation.global_position

	$CyberWorldPlayer.visible = true
	$CyberWorldPlayer.set_process(true)
	
	$CyberWorldPlayer.reset()

	$CyberWorldPlayer.respawned()

func end_game(won: bool) -> void:
	get_node("Defences").save_defences()
	$SceneTransitionAnimation.visible = true
	$UI.visible = false
	var animation: AnimationPlayer = $SceneTransitionAnimation/AnimationPlayer
	var camera = $SceneTransitionAnimation/Camera2D
	camera.make_current()

	if won:
		GameManager.reactor_destroyed = false
		# end of game
		if GameManager.current_round >= 5:  
			animation.play("game_end")
			await  animation.animation_finished
			GameManager.reset()
			GameManager.change_scene(GameManager.START_MENU_SCENE)
			return
		animation.play("mission_accomplished")
		await  get_tree().create_timer(4).timeout
		if GameManager.current_round == 4:
			GameManager.change_scene(GameManager.ENDING)
		else:
			GameManager.change_scene(GameManager.QUESTION_SCENE)
	else:
		if GameManager.reactor_destroyed:
			GameManager.reactor_destroyed = false
			animation.play("game_over")
			await  get_tree().create_timer(4).timeout
			GameManager.reset()
			GameManager.change_scene(GameManager.START_MENU_SCENE)
		else:
			GameManager.reactor_destroyed = true
			GameManager.add_knowledge_points(500)
			animation.play("mission_failed")
			await  get_tree().create_timer(4).timeout
			GameManager.change_scene(GameManager.REAL_WORLD_MAP_SCENE)
			
			
