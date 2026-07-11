extends CanvasLayer

const ItemScript = preload("res://Scripts/Mecanicas/item.gd")
const SLOT_COUNT = 10
var selected_slot := 0
var slots: Array = []
var slots_container: HBoxContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("action_bar")
	slots_container = find_child("HBoxContainer", true, false)
	_build_slots()
	_update_selection()
	Inventory.inventory_changed.connect(_refresh)

func _build_slots() -> void:
	for i in SLOT_COUNT:
		var slot := InventorySlot.new()
		slot.slot_index = i
		slot.slot_type = InventorySlot.SlotType.ACTION_BAR
		slot.custom_minimum_size = Vector2(52, 52)
		slot.mouse_filter = Control.MOUSE_FILTER_STOP

		var style_normal := StyleBoxFlat.new()
		style_normal.bg_color = Color(0.05, 0.05, 0.08, 0.85)
		style_normal.border_width_left = 2
		style_normal.border_width_top = 2
		style_normal.border_width_right = 2
		style_normal.border_width_bottom = 2
		style_normal.border_color = Color(0.4, 0.35, 0.15, 1)
		slot.add_theme_stylebox_override("panel", style_normal)
		slot.set_meta("style_normal", style_normal)

		var style_selected := StyleBoxFlat.new()
		style_selected.bg_color = Color(0.15, 0.13, 0.04, 0.95)
		style_selected.border_width_left = 2
		style_selected.border_width_top = 2
		style_selected.border_width_right = 2
		style_selected.border_width_bottom = 2
		style_selected.border_color = Color(1, 0.85, 0.3, 1)
		slot.set_meta("style_selected", style_selected)

		var vbox := VBoxContainer.new()
		vbox.name = "VBox"
		vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(vbox)

		var key_label := Label.new()
		key_label.text = str((i + 1) % 10)
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		key_label.add_theme_font_size_override("font_size", 10)
		key_label.add_theme_color_override("font_color", Color(0.6, 0.55, 0.35, 1))
		key_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		key_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(key_label)

		var icon := TextureRect.new()
		icon.name = "Icon"
		icon.custom_minimum_size = Vector2(32, 32)
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(icon)

		slots_container.add_child(slot)
		slots.append(slot)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		for i in 9:
			if event.keycode == KEY_1 + i:
				_select_slot(i)
				return
		if event.keycode == KEY_0:
			_select_slot(9)
			return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_select_slot((selected_slot - 1 + SLOT_COUNT) % SLOT_COUNT)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_select_slot((selected_slot + 1) % SLOT_COUNT)

func _select_slot(index: int) -> void:
	selected_slot = index
	_update_selection()

func _update_selection() -> void:
	for i in slots.size():
		var slot = slots[i]
		if i == selected_slot:
			slot.add_theme_stylebox_override("panel", slot.get_meta("style_selected"))
		else:
			slot.add_theme_stylebox_override("panel", slot.get_meta("style_normal"))

func _refresh() -> void:
	for i in slots.size():
		var slot = slots[i]
		var icon = slot.get_node_or_null("VBox/Icon")
		if icon == null:
			continue
		var item = Inventory.get_action_bar_slot(i)
		if item:
			icon.texture = ItemScript.get_texture(item.type)
		else:
			icon.texture = null

func get_selected_slot() -> int:
	return selected_slot

func get_selected_item() -> Variant:
	return Inventory.get_action_bar_slot(selected_slot)
