extends Control

# Load the game manager to control the KP logic
@onready var game_manager = get_node("/root/GameManager")  # Ensure your GameManager is at this path

# References (adjusted for the BackGround node)
@onready var balance_label = $BackGround/MainVBox/HBoxContainer/BalanceLabel
@onready var defenses_grid = $BackGround/MainVBox/CategoryContent/DefensesScroll/DefensesGrid
@onready var upgrades_grid = $BackGround/MainVBox/CategoryContent/UpgradesScroll/UpgradesGrid
@onready var powerups_grid = $BackGround/MainVBox/CategoryContent/PowerUpsScroll/PowerUpsGrid
@onready var tab_buttons = {
	"Defenses": $BackGround/MainVBox/CategoryTabs/DefensesButton,
	"Upgrades": $BackGround/MainVBox/CategoryTabs/UpgradesButton,
	"PowerUps": $BackGround/MainVBox/CategoryTabs/PowerUpsButton
}

var ItemCardScene = preload("res://Scenes/UIScenes/ItemCard.tscn")

func _ready() -> void:
	# Connect the kp_changed signal from the GameManager to update the balance display.
	GameManager.kp_changed.connect(update_balance_display)
	GameManager.round_updated.connect(update_shop)
	update_balance_display(GameManager.knowledge_points)
	
	# Connect category buttons using Godot 4's new signal connection syntax with binding.
	for category in tab_buttons.keys():
		var button = tab_buttons[category]
		# Bind the category to the _on_category_selected function.
		var callable = Callable(self, "_on_category_selected").bind(category)
		button.pressed.connect(callable)
	
	_on_category_selected("Defenses")

func update_balance_display(new_kp):
	balance_label.text = "Balance: %d KP" % new_kp

func update_shop(new_round: int):
	populate_category("Defenses", get_sample_items("Defenses"))  # unlock new defenses

func _on_category_selected(category: String) -> void:
	# Hide all category scroll containers
	$BackGround/MainVBox/CategoryContent/DefensesScroll.visible = false
	$BackGround/MainVBox/CategoryContent/UpgradesScroll.visible = false
	$BackGround/MainVBox/CategoryContent/PowerUpsScroll.visible = false
	
	# Show the selected category container
	match category:
		"Defenses":
			$BackGround/MainVBox/CategoryContent/DefensesScroll.visible = true
		"Upgrades":
			$BackGround/MainVBox/CategoryContent/UpgradesScroll.visible = true
		"PowerUps":
			$BackGround/MainVBox/CategoryContent/PowerUpsScroll.visible = true
	# Populate the selected category
	populate_category(category, get_sample_items(category))  # <-- Ensure items are loaded when switching tabs
	
func populate_category(category: String, items: Array) -> void:
	var grid: GridContainer = null
	match category:
		"Defenses":
			grid = defenses_grid
		"Upgrades":
			grid = upgrades_grid
		"PowerUps":
			grid = powerups_grid
	
	# Clear existing children in the grid.
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()

	var unlocked_defenses = GameManager.get_unlocked_defenses()

	# Add item cards dynamically.
	for i in range(items.size()):
		var item = items[i]
		#if category == "Defenses" and item.name not in unlocked_defenses:
			#continue  # skip the defenses that are locked
		var card = ItemCardScene.instantiate()
		# Set the icon on the front side.
		var icon_node = card.get_node("FrontSide/VBoxContainer/Icon")
		if icon_node and icon_node is TextureRect:
			icon_node.texture = item.icon
		else:
			printerr("Icon node not found or is not a TextureRect")
		
		# Set the front side's description label to the item name.
		var front_label = card.get_node("FrontSide/VBoxContainer/DescriptionLabel")
		if front_label and front_label is Label:
			front_label.text = item.name
		else:
			printerr("DescriptionLabel (front) node not found or is not a Label")
		
		# Set the cost label.
		var cost_label = card.get_node("FrontSide/VBoxContainer/HBoxContainer/CostLabel")
		if cost_label and cost_label is Label:
			cost_label.text = "%d KP" % item.cost
		else:
			printerr("CostLabel node not found or is not a Label")
		
		# Set the back side's ContextLabel to the full description.
		var context_label = card.get_node("BackSide/VBoxContainer/ContextLabel")
		if context_label and context_label is Label:
			context_label.text = item.description
		else:
			printerr("ContextLabel node not found or is not a Label")
		
		# Connect the purchase button so that clicking it triggers the purchase.
		var purchase_button = card.get_node("FrontSide/VBoxContainer/PurchaseButton")
		if purchase_button and purchase_button is Button:
			var callable = Callable(self, "_on_purchase_item").bind(item)
			purchase_button.pressed.connect(callable)
		else:
			printerr("PurchaseButton node not found or is not a Button")
			
		# Show the owned number of such defences
		var owned_label = card.get_node("FrontSide/VBoxContainer/HBoxContainer/OwnedCountLabel")
		if category == "Defenses":
			if owned_label and owned_label is Label:
				var owned_count = DefenseManager.get_deploy_count(item.name)
				owned_label.text = "Owned: %d" % owned_count
		else : 
			owned_label.get_parent().remove_child(owned_label)
			owned_label.queue_free()

		var lock_overlay = card.get_node("LockOverlay")  # get the Grey Translucent Screen
		
		var is_locked := false

		if category == "Defenses":
			is_locked = item.name not in unlocked_defenses
		elif category == "Upgrades":
			is_locked = i > 1  
		elif category == "PowerUps":
			is_locked = true 

		if is_locked:
			if lock_overlay:
				lock_overlay.visible = true
				lock_overlay.z_index = 1
				purchase_button.disabled = true
				purchase_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			if lock_overlay:
				lock_overlay.visible = false
				lock_overlay.z_index = -1
				purchase_button.disabled = false
				purchase_button.mouse_filter = Control.MOUSE_FILTER_STOP
				

		grid.add_child(card)

func _on_purchase_item(item: Dictionary) -> void:
	if GameManager.spend_knowledge_points(item.cost):
		DefenseManager.modify_deploy_count(item.name, 1)
		
		match item.name:
			"Overclocked Firewall":
				DefenseManager.upgrade_fire_rate()

			"Big Data Surge":
				DefenseManager.upgrade_damage_boost()
		# refresh the owned defence number in a simple way
		_on_category_selected("Defenses")
	else:
		printerr("Not enough KP for: ", item.description)

# Sample data function returning 6 items per category.
func get_sample_items(category: String) -> Array:
	if category == "Defenses":
		return [
			{"icon": preload("res://Assets/Defenses/Firewall-nb.png"), "name": "FIREWALL", "description": "A robust firewall system that inspects incoming traffic to block malicious data packets. Inspired by early network defenses..", "cost": 100},
			{"icon": preload("res://Assets/Defenses/towerDefense_tile249.png"), "name": "ANTI-MALWARE TURRET", "description": "Monitors and analyzes network activity with precision, detecting anomalies before they become threats.", "cost": 300},
			{"icon": preload("res://Assets/Defenses/towerDefense_turret3.png"), "name": "ANTI-VIRUS", "description": "Utilises signature-based detection and heuristics to neutralise viruses, spyware, and rootkits.", "cost": 300},
			{"icon": preload("res://Assets/Defenses/towerDefense_tile205.png"), "name": "AI SPAM-FILTER", "description": "Filters out suspicious links and abnormal email patterns to ward off social engineering attacks.", "cost": 500},
			{"icon": preload("res://Assets/Defenses/trojanTower.png"), "name": "TROJAN BUSTER", "description": "Encrypts and tunnels network data—perfect for defending against man-in-the-middle attacks on open networks.", "cost": 400},
			{"icon": preload("res://Assets/Defenses/sqlTower.png"), "name": "SQL ENERVATOR", "description": "Specialised measures to identify and isolate Trojan and hijacker malware, ensuring system integrity.", "cost": 750},
		]
	elif category == "Upgrades":
		return [
			{"icon": preload("res://Assets/PowerUps-Upgrades/Item_Powerup_7.png"), "name": "Overclocked Firewall", "description": "Turrets fire 25% faster while active.", "cost": 300},
			# In‐game effect: Once purchased, every turret’s firing rate increases by 25% for the entire game,
			{"icon": preload("res://Assets/PowerUps-Upgrades/Item_Powerup_13.png"), "name": "Big Data Surge", "description": "Temporarily boosts turret damage output by 50% for 10 seconds.", "cost": 350},
			# In‐game effect: Once activated, all turrets on the field deal 50% increased damage for 10 seconds,
			{"icon": preload("res://Assets/PowerUps-Upgrades/Item_Powerup_19.png"), "name": "Encrypted Data Mine", "description": "Empowers turrets with a chance to trigger an explosive area attack.", "cost": 400},
			# In‐game effect: Turrets occasionally launch a special shot that deals splash damage and briefly stuns enemies
			{"icon": preload("res://Assets/PowerUps-Upgrades/Item_Powerup_Control_1.png"), "name": "Botnet Barrage Module", "description": "Enables turrets to fire a rapid volley that targets multiple enemies.", "cost": 500},
			# In‐game effect: When activated, each turret gains a chance to release a multi-shot barrage that
			{"icon": preload("res://Assets/PowerUps-Upgrades/Item_Powerup_6.png"), "name": "Quantum Threat Analyzer", "description": "Extends turret range and improves threat prioritisation", "cost": 320},
			# In‐game effect: Turrets enjoy an increased attack range (about 15% extra) and will automatically
			{"icon": preload("res://Assets/PowerUps-Upgrades/Item_Other_Misc_1.png"), "name": "Virtual Sentinel Upgrade", "description": "Quick system repair upgrade for all turrets.", "cost": 280}
			# In‐game effect: A digital boost is added to your turret network, enabling one time full health repairs

		]
	elif category == "PowerUps":
		return [
			{"icon": preload("res://Assets/PowerUps-Upgrades/Box_Item_8.png"), "name": "Cloaking Protocol", "description": "Activate a digital cloak that makes you temporarily invulnerable.", "cost": 600},
			# In‑game effect: Grants the player full invincibility for 6 seconds, allowing safe passage through enemy fire.
			{"icon": preload("res://Assets/PowerUps-Upgrades/Box_Item_3.png"), "name": "System Reboot", "description": "Instantly restores your full health bar—get back online without delay.", "cost": 450},
			# In‑game effect: When triggered, the player's health is fully restored, effectively acting as an emergency heal.
			{"icon": preload("res://Assets/PowerUps-Upgrades/Box_Item_2.png"), "name": "Overclocked Processor", "description": "Temporarily doubles your movement speed for rapid repositioning.", "cost": 400},
			# In‑game effect: When activated, the player's movement speed is increased 2x for 10 seconds, allowing quick escapes or repositioning.
			{"icon": preload("res://Assets/PowerUps-Upgrades/Box_Item_9.png"), "name": "Augmented Attack Suite", "description": "Boost your personal damage output by 2x for a short burst.", "cost": 550},
			# In‑game effect: This powerup doubles the player's damage output for 8 seconds, making each attack significantly more powerful.
			{"icon": preload("res://Assets/PowerUps-Upgrades/Box_Item_5.png"), "name": "Neural Interface Upgrade", "description": "Reduces your special ability cooldowns by half for a short period.", "cost": 480},
			# In‑game effect: Cuts the player's special ability cooldown times by 50% for 10 seconds, enabling more frequent use of powerful skills.
			{"icon": preload("res://Assets/PowerUps-Upgrades/Box_Item_15.png"), "name": "Digital Barrier", "description": "Generate a protective shield that reduces incoming damage by 50% for a brief moment.", "cost": 300}
			# In‑game effect: For 7 seconds the player takes 50% less damage, effectively boosting survivability during intense situations.
		]
	return []
