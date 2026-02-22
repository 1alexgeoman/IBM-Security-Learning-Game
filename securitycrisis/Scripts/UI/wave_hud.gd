extends Control

func _on_enemy_spawner_next_wave(wave_id) -> void:
	$RoundWaveLabel.text = "Round: %d Wave: %d" % [GameManager.current_round, wave_id + 1]

func _on_cyber_world_player_player_health_changed(new_health) -> void:
	$HealthBar/HealthLabel.text = "%d/%d" % [new_health, $HealthBar.max_value]
	$HealthBar.value = new_health
