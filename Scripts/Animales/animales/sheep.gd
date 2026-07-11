extends "res://Scripts/animales/base/animal.gd"

const Item = preload("res://Scripts/Mecanicas/item.gd")

func _setup() -> void:
	patrol_speed = 40.0
	flee_radius = 100.0
	flee_speed = 90.0

func _drop_loot() -> Array:
	var drops: Array = []

	# LANA — 100% x1, 50% x2
	var lana_qty := 1
	if randf() < 0.5:
		lana_qty = 2
	drops.append({ "type": Item.Type.LANA, "quantity": lana_qty })

	# CARNE — 100% x1, 50% x2
	var carne_qty := 1
	if randf() < 0.5:
		carne_qty = 2
	drops.append({ "type": Item.Type.CARNE, "quantity": carne_qty })

	# ESPIRITU_OVEJA — 1%
	if randf() < 0.01:
		drops.append({ "type": Item.Type.ESPIRITU_OVEJA, "quantity": 1 })

	return drops
