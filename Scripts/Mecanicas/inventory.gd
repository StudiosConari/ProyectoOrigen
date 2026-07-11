extends Node

signal inventory_changed
const Item = preload("res://Scripts/Mecanicas/item.gd")

const ROWS = 3
const COLS = 8
const SIZE = ROWS * COLS
const SPIRIT_SIZE = ROWS * COLS
const ACTION_BAR_SIZE = 10

var slots: Array = []
var spirit_slots: Array = []
var action_bar_slots: Array = []
var coins: int = 0

var equipped = {
	"weapon_main": null,
	"weapon_secondary": null,
	"helmet": null,
	"chest": null,
	"pants": null,
	"boots": null,
	"gloves": null,
	"ring": null,
	"collar": null,
	"belt": null,
	"aros": null,
	"mascota": null,
}

var imbued_spirits = {
	"spirit": null,
	"weapon_main": null,
	"weapon_secondary": null,
	"helmet": null,
	"chest": null,
	"pants": null,
	"boots": null,
	"gloves": null,
	"ring": null,
	"collar": null,
	"belt": null,
	"aros": null,
	"mascota": null,
}

func _ready() -> void:
	slots.resize(SIZE)
	spirit_slots.resize(SPIRIT_SIZE)
	action_bar_slots.resize(ACTION_BAR_SIZE)
	slots.fill(null)
	spirit_slots.fill(null)
	action_bar_slots.fill(null)

func add_item(item_type: int, quantity: int) -> bool:
	if item_type == Item.Type.MONEDAS:
		coins += quantity
		inventory_changed.emit()
		return true
	if item_type == Item.Type.ESPIRITU_LANCERO or item_type == Item.Type.ESPIRITU_OVEJA:
		return _add_to_slots(spirit_slots, item_type, quantity)
	return _add_to_slots(slots, item_type, quantity)

func _add_to_slots(slot_array: Array, item_type: int, quantity: int) -> bool:
	for i in slot_array.size():
		if slot_array[i] != null and slot_array[i].type == item_type:
			slot_array[i].quantity += quantity
			inventory_changed.emit()
			return true
	for i in slot_array.size():
		if slot_array[i] == null:
			slot_array[i] = { "type": item_type, "quantity": quantity }
			inventory_changed.emit()
			return true
	print("Inventario lleno!")
	return false

func remove_item(slot_index: int, from_spirits: bool = false) -> void:
	if from_spirits:
		spirit_slots[slot_index] = null
	else:
		slots[slot_index] = null
	inventory_changed.emit()

func compact(from_spirits: bool = false) -> void:
	var arr = spirit_slots if from_spirits else slots
	var items = arr.filter(func(x): return x != null)
	arr.fill(null)
	for i in items.size():
		arr[i] = items[i]
	inventory_changed.emit()

func move_item(from_index: int, to_index: int, from_spirits: bool = false, to_spirits: bool = false) -> void:
	var from_array = spirit_slots if from_spirits else slots
	var to_array = spirit_slots if to_spirits else slots
	var temp = to_array[to_index]
	to_array[to_index] = from_array[from_index]
	from_array[from_index] = temp
	# reordenar si queda hueco en el mismo array
	if from_array == to_array:
		compact(from_spirits)
	else:
		inventory_changed.emit()

func set_action_bar_slot(bar_index: int, item: Variant) -> void:
	if bar_index >= 0 and bar_index < ACTION_BAR_SIZE:
		action_bar_slots[bar_index] = item
		inventory_changed.emit()

func get_action_bar_slot(bar_index: int) -> Variant:
	if bar_index >= 0 and bar_index < ACTION_BAR_SIZE:
		return action_bar_slots[bar_index]
	return null
