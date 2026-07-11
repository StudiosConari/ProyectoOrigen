extends CanvasLayer

@onready var item_grid: GridContainer = $Panel/TabContainer/Inventario/ItemGrid
@onready var spirit_grid: GridContainer = $Panel/TabContainer/Espiritus/SpiritGrid
@onready var coins_label: Label = $Panel/CoinsLabel

const ItemScript = preload("res://Scripts/Mecanicas/item.gd")
const SLOT_SIZE = 48
const COLS = 8

# mapeo de equip_key → tipos permitidos y tipo de placeholder
const EQUIP_RULES = {
	"weapon_main":      { "types": [ItemData.Type.LANZA_COMPLETA, ItemData.Type.FRAGMENTO_ARMA], "placeholder_type": ItemData.Type.LANZA_COMPLETA },
	"weapon_secondary": { "types": [ItemData.Type.LANZA_COMPLETA, ItemData.Type.FRAGMENTO_ARMA], "placeholder_type": ItemData.Type.LANZA_COMPLETA },
	"helmet":           { "types": [ItemData.Type.CASCO],       "placeholder_type": ItemData.Type.CASCO },
	"chest":            { "types": [ItemData.Type.PECHERA],      "placeholder_type": ItemData.Type.PECHERA },
	"pants":            { "types": [ItemData.Type.PANTALONES],   "placeholder_type": ItemData.Type.PANTALONES },
	"boots":            { "types": [ItemData.Type.BOTAS],        "placeholder_type": ItemData.Type.BOTAS },
	"gloves":           { "types": [ItemData.Type.GUANTES],      "placeholder_type": ItemData.Type.GUANTES },
	"ring":             { "types": [ItemData.Type.ANILLO],       "placeholder_type": ItemData.Type.ANILLO },
	"collar":           { "types": [ItemData.Type.COLLAR],       "placeholder_type": ItemData.Type.COLLAR },
	"belt":             { "types": [ItemData.Type.CINTURON],     "placeholder_type": ItemData.Type.CINTURON },
	"spirit":           { "types": [ItemData.Type.ESPIRITU_LANCERO, ItemData.Type.ESPIRITU_OVEJA], "placeholder_type": ItemData.Type.ESPIRITU_OVEJA },
	"aros":             { "types": [ItemData.Type.AROS], "placeholder_type": ItemData.Type.AROS },
	"mascota":          { "types": [ItemData.Type.MASCOTA], "placeholder_type": ItemData.Type.MASCOTA },
	"spirit_spirit":           { "types": [], "placeholder_type": ItemData.Type.ESPIRITU_OVEJA },
	"spirit_weapon_main":      { "types": [], "placeholder_type": ItemData.Type.ESPIRITU_LANCERO },
	"spirit_weapon_secondary": { "types": [], "placeholder_type": ItemData.Type.ESPIRITU_LANCERO },
	"spirit_helmet":           { "types": [], "placeholder_type": ItemData.Type.ESPIRITU_OVEJA },
	"spirit_chest":            { "types": [], "placeholder_type": ItemData.Type.ESPIRITU_OVEJA },
	"spirit_pants":            { "types": [], "placeholder_type": ItemData.Type.ESPIRITU_OVEJA },
	"spirit_boots":            { "types": [], "placeholder_type": ItemData.Type.ESPIRITU_OVEJA },
	"spirit_gloves":           { "types": [], "placeholder_type": ItemData.Type.ESPIRITU_OVEJA },
	"spirit_ring":             { "types": [], "placeholder_type": ItemData.Type.ESPIRITU_OVEJA },
	"spirit_collar":           { "types": [], "placeholder_type": ItemData.Type.ESPIRITU_OVEJA },
	"spirit_belt":             { "types": [], "placeholder_type": ItemData.Type.ESPIRITU_OVEJA },
	"spirit_aros":             { "types": [], "placeholder_type": ItemData.Type.ESPIRITU_OVEJA },
	"spirit_mascota":          { "types": [], "placeholder_type": ItemData.Type.ESPIRITU_OVEJA },
}

func _ready() -> void:
	add_to_group("inventory_ui")
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build_grid(item_grid, Inventory.SIZE, false)
	_build_grid(spirit_grid, Inventory.SPIRIT_SIZE, true)
	_build_equip_slots()
	_build_spirit_equip_slots()
	Inventory.inventory_changed.connect(_refresh)
	_refresh()

func _build_grid(grid: GridContainer, size: int, is_spirits: bool) -> void:
	grid.columns = COLS
	grid.position = Vector2(5, 190)
	for i in size:
		var slot = _create_slot(i, is_spirits)
		grid.add_child(slot)

func _create_slot(index: int, is_spirits: bool) -> InventorySlot:
	var slot = InventorySlot.new()
	slot.slot_index = index
	slot.slot_type = InventorySlot.SlotType.SPIRIT if is_spirits else InventorySlot.SlotType.INVENTORY
	slot.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
	var icon = TextureRect.new()
	icon.name = "Icon"
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	slot.add_child(icon)
	var qty_label = Label.new()
	qty_label.name = "Qty"
	qty_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	qty_label.add_theme_font_size_override("font_size", 10)
	slot.add_child(qty_label)
	return slot

func _build_equip_slots() -> void:
	var panel = $Panel/TabContainer/Inventario/CharacterPanel
	_add_equip_slot(panel, "spirit",           "Espiritu", Vector2(100, 20),  48, false)
	_add_equip_slot(panel, "weapon_main",      "Arma 1",   Vector2(100, 76),  48, false)
	_add_equip_slot(panel, "gloves",           "Guantes",  Vector2(100, 136), 48, false)
	_add_equip_slot(panel, "collar",           "Collar",   Vector2(160, 88),  24, false)
	_add_equip_slot(panel, "ring",             "Anillo",   Vector2(160, 148), 24, false)
	_add_equip_slot(panel, "helmet",           "Casco",    Vector2(192, 20),  48, false)
	_add_equip_slot(panel, "chest",            "Pechera",  Vector2(192, 76),  48, false)
	_add_equip_slot(panel, "pants",            "Pantalon", Vector2(192, 136), 48, false)
	_add_equip_slot(panel, "aros",             "Aros",     Vector2(252, 88),  24, false)
	_add_equip_slot(panel, "belt",             "Cinturon", Vector2(252, 148), 24, false)
	_add_equip_slot(panel, "mascota",          "Mascota",  Vector2(284, 20),  48, false)
	_add_equip_slot(panel, "weapon_secondary", "Arma 2",   Vector2(284, 76),  48, false)
	_add_equip_slot(panel, "boots",            "Botas",    Vector2(284, 136), 48, false)

func _build_spirit_equip_slots() -> void:
	var panel = $Panel/TabContainer/Espiritus/CharacterPanel
	_add_equip_slot(panel, "spirit_spirit",           "Esp.Espiritu", Vector2(100, 20),  48, true)
	_add_equip_slot(panel, "spirit_weapon_main",      "Esp.Arma1",    Vector2(100, 76),  48, true)
	_add_equip_slot(panel, "spirit_gloves",           "Esp.Guantes",  Vector2(100, 136), 48, true)
	_add_equip_slot(panel, "spirit_collar",           "Esp.Collar",   Vector2(160, 88),  24, true)
	_add_equip_slot(panel, "spirit_ring",             "Esp.Anillo",   Vector2(160, 148), 24, true)
	_add_equip_slot(panel, "spirit_helmet",           "Esp.Casco",    Vector2(192, 20),  48, true)
	_add_equip_slot(panel, "spirit_chest",            "Esp.Pechera",  Vector2(192, 76),  48, true)
	_add_equip_slot(panel, "spirit_pants",            "Esp.Pantalon", Vector2(192, 136), 48, true)
	_add_equip_slot(panel, "spirit_aros",             "Esp.Aros",     Vector2(252, 88),  24, true)
	_add_equip_slot(panel, "spirit_belt",             "Esp.Cinturon", Vector2(252, 148), 24, true)
	_add_equip_slot(panel, "spirit_mascota",          "Esp.Mascota",  Vector2(284, 20),  48, true)
	_add_equip_slot(panel, "spirit_weapon_secondary", "Esp.Arma2",    Vector2(284, 76),  48, true)
	_add_equip_slot(panel, "spirit_boots",            "Esp.Botas",    Vector2(284, 136), 48, true)

func _add_equip_slot(parent: Control, key: String, label: String, pos: Vector2, size: int, is_spirit: bool) -> void:
	var slot = InventorySlot.new()
	slot.name = "Equip_" + key
	slot.equip_key = key
	slot.slot_type = InventorySlot.SlotType.SPIRIT_EQUIP if is_spirit else InventorySlot.SlotType.EQUIP
	slot.custom_minimum_size = Vector2(size, size)
	slot.size = Vector2(size, size)
	slot.position = pos
	slot.tooltip_text = label

	# asignar tipos permitidos y placeholder
	var base_key = key.trim_prefix("spirit_")
	if EQUIP_RULES.has(base_key):
		var rule = EQUIP_RULES[base_key]
		if not is_spirit:
			slot.allowed_types = rule.types
		slot.placeholder_texture = ItemScript.get_texture(rule.placeholder_type)

	var icon = TextureRect.new()
	icon.name = "Icon"
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	slot.add_child(icon)
	parent.add_child(slot)

func _apply_grayscale(node: TextureRect) -> void:
	var shader = Shader.new()
	shader.code = """
shader_type canvas_item;
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float g = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(vec3(g), c.a * 0.35);
}
"""
	var mat = ShaderMaterial.new()
	mat.shader = shader
	node.material = mat

func _apply_grayscale_spirit(node: TextureRect) -> void:
	var shader = Shader.new()
	shader.code = """
shader_type canvas_item;
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float g = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(g * 0.4, g * 0.75, g * 1.0, c.a * 0.35);
}
"""
	var mat = ShaderMaterial.new()
	mat.shader = shader
	node.material = mat

func _apply_grayscale_clear(node: TextureRect) -> void:
	node.material = null
	node.modulate = Color.WHITE

func _refresh() -> void:
	coins_label.text = "Monedas: " + str(Inventory.coins)
	coins_label.position = Vector2(10, 380)
	_refresh_grid(item_grid, Inventory.slots)
	_refresh_grid(spirit_grid, Inventory.spirit_slots)
	_refresh_equip_slots()

func _refresh_grid(grid: GridContainer, slot_array: Array) -> void:
	for i in grid.get_child_count():
		var slot = grid.get_child(i)
		var icon = slot.get_node("Icon")
		var qty = slot.get_node("Qty")
		if slot_array[i] != null:
			icon.texture = ItemScript.get_texture(slot_array[i].type)
			icon.modulate = Color.WHITE
			var quantity = slot_array[i].quantity
			qty.text = "x" + str(quantity) if quantity > 1 else ""
		else:
			icon.texture = null
			icon.modulate = Color.WHITE
			qty.text = ""

func _refresh_equip_slots() -> void:
	var inv_panel = $Panel/TabContainer/Inventario/CharacterPanel
	for child in inv_panel.get_children():
		if child is InventorySlot and child.slot_type == InventorySlot.SlotType.EQUIP:
			var icon = child.get_node("Icon")
			var item = Inventory.equipped.get(child.equip_key)
			if item:
				icon.texture = ItemScript.get_texture(item.type)
				_apply_grayscale_clear(icon)
			else:
				# mostrar placeholder semitransparente
				icon.texture = child.placeholder_texture
				icon.modulate = Color.WHITE
				_apply_grayscale(icon)

	var spirit_panel = $Panel/TabContainer/Espiritus/CharacterPanel
	for child in spirit_panel.get_children():
		if child is InventorySlot and child.slot_type == InventorySlot.SlotType.SPIRIT_EQUIP:
			var icon = child.get_node("Icon")
			var spirit = Inventory.imbued_spirits.get(child.equip_key)
			if spirit:
				icon.texture = ItemScript.get_texture(spirit.type)
				_apply_grayscale_clear(icon)
			else:
				icon.texture = child.placeholder_texture
				icon.modulate = Color.WHITE
				_apply_grayscale_spirit(icon)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_inventory"):
		visible = !visible
		var _ui_mgr = get_node_or_null("/root/UiManager")
		if _ui_mgr:
			_ui_mgr.notify_visibility_changed()
