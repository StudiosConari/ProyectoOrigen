class_name EnemyLancero extends Enemy

@export var level := 2

func _setup() -> void:
	move_speed = 100
	attack_damage = 10
	detection_range = 200.0
	attack_range = 60.0
	height_level = 1
	hear_range = 80.0
	attack_cooldown = 1.5
	exp_reward = level * 10
	class_exp_reward = level * 10

	loot_table = LootTable.new()
	loot_table.min_coins = 10 * level
	loot_table.max_coins = 50 * level
	loot_table.bonus_coins_chance = 3.0
	loot_table.bonus_coins_multiplier = 10
	loot_table.entries = [
		{ "item": Item.Type.LANZA_COMPLETA,     "chance": 20.0, "min_qty": 1, "max_qty": 1 },
		{ "item": Item.Type.FRAGMENTO_ARMA,     "chance": 10.0, "min_qty": 1, "max_qty": 3 },
		{ "item": Item.Type.CASCO,              "chance": 25.0, "min_qty": 1, "max_qty": 1 },
		{ "item": Item.Type.PECHERA,            "chance": 25.0, "min_qty": 1, "max_qty": 1 },
		{ "item": Item.Type.PANTALONES,         "chance": 25.0, "min_qty": 1, "max_qty": 1 },
		{ "item": Item.Type.BOTAS,              "chance": 25.0, "min_qty": 1, "max_qty": 1 },
		{ "item": Item.Type.GUANTES,            "chance": 25.0, "min_qty": 1, "max_qty": 1 },
		{ "item": Item.Type.FRAGMENTO_ARMADURA, "chance": 10.0, "min_qty": 1, "max_qty": 3 },
		{ "item": Item.Type.NUCLEO_LANCERO,     "chance": 10.0, "min_qty": 1, "max_qty": 1 },
		{ "item": Item.Type.ESPIRITU_LANCERO,   "chance": 2.0,  "min_qty": 1, "max_qty": 1 },
		{ "item": Item.Type.ANILLO,             "chance": 10.0, "min_qty": 1, "max_qty": 1 },
		{ "item": Item.Type.COLLAR,             "chance": 10.0, "min_qty": 1, "max_qty": 1 },
		{ "item": Item.Type.CINTURON,           "chance": 10.0, "min_qty": 1, "max_qty": 1 },
		{ "item": Item.Type.AROS,               "chance": 10.0, "min_qty": 1, "max_qty": 1 },
	]
