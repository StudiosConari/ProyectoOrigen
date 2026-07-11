class_name InventorySlot
extends Panel

const ItemScript = preload("res://Scripts/Mecanicas/item.gd")

enum SlotType { INVENTORY, EQUIP, SPIRIT, SPIRIT_EQUIP, ACTION_BAR }

var slot_index: int = -1
var slot_type: SlotType = SlotType.INVENTORY
var equip_key: String = ""
var allowed_types: Array = []  # tipos de Item.Type permitidos, vacío = todos
var placeholder_texture: Texture2D = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if placeholder_texture:
		var ph = get_node_or_null("Icon")
		if ph and ph.texture == null:
			ph.texture = placeholder_texture
			ph.modulate = Color(1, 1, 1, 0.3)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	var data = _get_slot_data()
	if data == null:
		return
	ItemTooltip.show_tooltip(data.type, get_global_mouse_position())

func _on_mouse_exited() -> void:
	ItemTooltip.hide_tooltip()

func _get_drag_data(_position: Vector2) -> Variant:
	var data = _get_slot_data()
	if data == null:
		return null

	var preview = Panel.new()
	preview.custom_minimum_size = Vector2(48, 48)
	var icon = TextureRect.new()
	icon.texture = ItemScript.get_texture(data.type)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	preview.add_child(icon)
	set_drag_preview(preview)

	return {
		"from_index": slot_index,
		"from_type": slot_type,
		"from_key": equip_key,
		"item": data
	}

func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	if data == null or not data is Dictionary:
		return false
	if data.from_index == slot_index and data.from_type == slot_type:
		return false
	# la barra de acción solo acepta items del inventario principal
	if slot_type == SlotType.ACTION_BAR:
		return data.from_type == SlotType.INVENTORY or data.from_type == SlotType.ACTION_BAR
	# validar tipo permitido
	if allowed_types.size() > 0 and data.item != null:
		if not data.item.type in allowed_types:
			return false
	return true

func _drop_data(_position: Vector2, data: Variant) -> void:
	if data == null:
		return

	var from_index: int = data.from_index
	var from_type: SlotType = data.from_type
	var from_key: String = data.from_key

	if slot_type == SlotType.INVENTORY and from_type == SlotType.INVENTORY:
		Inventory.move_item(from_index, slot_index, false, false)
	elif slot_type == SlotType.SPIRIT and from_type == SlotType.SPIRIT:
		Inventory.move_item(from_index, slot_index, true, true)
	elif slot_type == SlotType.EQUIP and from_type == SlotType.INVENTORY:
		_equip_from_inventory(from_index, equip_key)
	elif slot_type == SlotType.INVENTORY and from_type == SlotType.EQUIP:
		_unequip_to_inventory(from_key, slot_index)
	elif slot_type == SlotType.SPIRIT_EQUIP and from_type == SlotType.SPIRIT:
		_imbue_spirit(from_index, equip_key)
	elif slot_type == SlotType.SPIRIT and from_type == SlotType.SPIRIT_EQUIP:
		_unimbue_spirit(from_key, slot_index)
	# barra de acción — desde inventario
	elif slot_type == SlotType.ACTION_BAR and from_type == SlotType.INVENTORY:
		_assign_to_action_bar(from_index, slot_index)
	# barra de acción — mover entre slots de la barra
	elif slot_type == SlotType.ACTION_BAR and from_type == SlotType.ACTION_BAR:
		_swap_action_bar(from_index, slot_index)
	# devolver desde barra al inventario
	elif slot_type == SlotType.INVENTORY and from_type == SlotType.ACTION_BAR:
		_return_from_action_bar(from_index, slot_index)

func _get_slot_data() -> Variant:
	match slot_type:
		SlotType.INVENTORY:
			return Inventory.slots[slot_index]
		SlotType.SPIRIT:
			return Inventory.spirit_slots[slot_index]
		SlotType.EQUIP:
			return Inventory.equipped.get(equip_key)
		SlotType.SPIRIT_EQUIP:
			return Inventory.imbued_spirits.get(equip_key)
		SlotType.ACTION_BAR:
			return Inventory.get_action_bar_slot(slot_index)
	return null

func _equip_from_inventory(from_index: int, to_key: String) -> void:
	var item = Inventory.slots[from_index]
	if item == null:
		return
	var currently_equipped = Inventory.equipped.get(to_key)
	if currently_equipped:
		Inventory.slots[from_index] = currently_equipped
	else:
		Inventory.slots[from_index] = null
	Inventory.equipped[to_key] = item
	Stats.apply_equipment_stats(item.type)
	Inventory.compact(false)

func _unequip_to_inventory(from_key: String, to_index: int) -> void:
	var item = Inventory.equipped.get(from_key)
	if item == null:
		return
	var currently_in_slot = Inventory.slots[to_index]
	Inventory.slots[to_index] = item
	Stats.remove_equipment_stats(item.type)
	if currently_in_slot:
		Inventory.equipped[from_key] = currently_in_slot
		Stats.apply_equipment_stats(currently_in_slot.type)
	else:
		Inventory.equipped[from_key] = null
	Inventory.inventory_changed.emit()

func _imbue_spirit(from_index: int, to_key: String) -> void:
	var spirit = Inventory.spirit_slots[from_index]
	if spirit == null:
		return
	var currently_imbued = Inventory.imbued_spirits.get(to_key)
	if currently_imbued:
		Inventory.spirit_slots[from_index] = currently_imbued
	else:
		Inventory.spirit_slots[from_index] = null
	Inventory.imbued_spirits[to_key] = spirit
	Inventory.inventory_changed.emit()

func _unimbue_spirit(from_key: String, to_index: int) -> void:
	var spirit = Inventory.imbued_spirits.get(from_key)
	if spirit == null:
		return
	var currently_in_slot = Inventory.spirit_slots[to_index]
	Inventory.spirit_slots[to_index] = spirit
	if currently_in_slot:
		Inventory.imbued_spirits[from_key] = currently_in_slot
	else:
		Inventory.imbued_spirits[from_key] = null
	Inventory.inventory_changed.emit()

func _assign_to_action_bar(from_inv_index: int, to_bar_index: int) -> void:
	var item = Inventory.slots[from_inv_index]
	if item == null:
		return
	var current = Inventory.get_action_bar_slot(to_bar_index)
	if current:
		Inventory.slots[from_inv_index] = current
	else:
		Inventory.slots[from_inv_index] = null
	Inventory.set_action_bar_slot(to_bar_index, item)
	Inventory.compact(false)

func _swap_action_bar(from_bar_index: int, to_bar_index: int) -> void:
	var item_a = Inventory.get_action_bar_slot(from_bar_index)
	var item_b = Inventory.get_action_bar_slot(to_bar_index)
	Inventory.set_action_bar_slot(from_bar_index, item_b)
	Inventory.set_action_bar_slot(to_bar_index, item_a)

func _return_from_action_bar(from_bar_index: int, to_inv_index: int) -> void:
	var item = Inventory.get_action_bar_slot(from_bar_index)
	if item == null:
		return
	var current = Inventory.slots[to_inv_index]
	Inventory.slots[to_inv_index] = item
	Inventory.set_action_bar_slot(from_bar_index, current)
