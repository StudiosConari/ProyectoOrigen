class_name LootTable
extends Resource

@export var entries: Array = []
const Item = preload("res://Scripts/Mecanicas/item.gd")
const DROP_COUNT_TABLE = [
	{ "count": 6, "chance": 1.0 },
	{ "count": 5, "chance": 2.0 },
	{ "count": 4, "chance": 5.0 },
	{ "count": 3, "chance": 10.0 },
	{ "count": 2, "chance": 30.0 },
	{ "count": 1, "chance": 60.0 },
	{ "count": 0, "chance": 100.0 },
]

const ALL_ITEMS_CHANCE = 0.01

var min_coins := 10
var max_coins := 50
var bonus_coins_chance := 3.0
var bonus_coins_multiplier := 10

func roll() -> Array:
	var drops: Array = []

	# slot 1 — monedas SIEMPRE garantizadas
	var coin_qty := randi_range(min_coins, max_coins)
	if randf() * 100.0 <= bonus_coins_chance:
		coin_qty *= bonus_coins_multiplier
	# FIX #1: usar el enum en vez del índice hardcodeado
	drops.append({ "type": Item.Type.MONEDAS, "quantity": coin_qty })

	# caso especial todos los items (0.01%)
	if randf() * 100.0 <= ALL_ITEMS_CHANCE:
		for entry in entries:
			var qty := randi_range(entry.min_qty, entry.max_qty)
			drops.append({ "type": entry.item, "quantity": qty })
		return drops

	# determinar cuántos items EXTRA
	var extra_count := 0
	var tirada := randf() * 100.0
	for row in DROP_COUNT_TABLE:
		if tirada <= row.chance:
			extra_count = row.count
			break

	if extra_count == 0:
		return drops

	# elegir items de la tabla
	var available_entries = entries.duplicate()
	available_entries.shuffle()

	var attempts := 0
	var chosen: Array = []

	while chosen.size() < extra_count and attempts < 100:
		attempts += 1
		for entry in available_entries:
			if chosen.size() >= extra_count:
				break
			var already_chosen := false
			for c in chosen:
				if c.type == entry.item:
					already_chosen = true
					break
			if already_chosen:
				continue
			if randf() * 100.0 <= entry.chance:
				var qty := randi_range(entry.min_qty, entry.max_qty)
				chosen.append({ "type": entry.item, "quantity": qty })

	drops.append_array(chosen)
	return drops
