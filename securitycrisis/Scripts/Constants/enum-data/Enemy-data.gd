class_name Enemy_data

const _data: Dictionary = {
	ENEMIES.DDOS_SPAM: preload("res://Scenes/objects/Enemies/DDOS.tscn"),
	ENEMIES.MALWARE_VIRUS: preload("res://Scenes/objects/Enemies/Virus.tscn"),
	ENEMIES.PHISHING: preload("res://Scenes/objects/Enemies/PhishingEnemy.tscn"),
	ENEMIES.MALWARE_TROJAN: preload("res://Scenes/objects/Enemies/TrojanEnemy.tscn"),
	ENEMIES.SQL_INJECTION: preload("res://Scenes/objects/Enemies/SQLInjectionEnemy.tscn")
}

static func get_enemy(enemy) -> PackedScene:
	return _data[enemy]
