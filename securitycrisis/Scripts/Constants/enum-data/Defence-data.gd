class_name Defence_data

const _data: Dictionary = {
	DEFENCES.ANTI_MALWARE: preload("res://Scenes/objects/Defenses/ANTI-MALWARE TURRET.tscn"),
	DEFENCES.FIREWALL: preload("res://Scenes/objects/Defenses/FIREWALL.tscn"),
	DEFENCES.AI_SPAM_FILTER: preload("res://Scenes/objects/Defenses/AI SPAM-FILTER.tscn"),
	DEFENCES.ANTI_VIRUS: preload("res://Scenes/objects/Defenses/ANTI-VIRUS.tscn"),
	DEFENCES.TROJAN_BUSTER: preload("res://Scenes/objects/Defenses/TROJAN BUSTER.tscn"),
	DEFENCES.ANTI_SQL_INJECTION: preload("res://Scenes/objects/Defenses/SQL ENERVATOR.tscn")
}

static func get_defence(defence) -> PackedScene:
	return _data[defence]
