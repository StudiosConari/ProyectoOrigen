extends Node

const PANEL_GAP := 2.0
const INV_LEFT := 1480.0
const INV_TOP := 50.0
const INV_RIGHT := -30.0
const INV_HEIGHT := 390.0
const PANEL_HEIGHT := 380.0

func _find_nodes() -> void:
	if not inventory_ui:
		inventory_ui = get_tree().get_first_node_in_group("inventory_ui")
	if not stats_ui:
		stats_ui = get_tree().get_first_node_in_group("stats_ui")
	if not skills_ui:
		skills_ui = get_tree().get_first_node_in_group("skills_ui")

var inventory_ui = null
var stats_ui = null
var skills_ui = null

func notify_visibility_changed() -> void:
	await get_tree().process_frame
	_find_nodes()
	_reorganize()

func _reorganize() -> void:
	var inv_visible: bool = inventory_ui != null and inventory_ui.visible
	var stats_visible: bool = stats_ui != null and stats_ui.visible
	var skills_visible: bool = skills_ui != null and skills_ui.visible

	var next_top := INV_TOP
	if inv_visible:
		# calcular altura real del panel del inventario
		var inv_panel = inventory_ui.get_node_or_null("Panel")
		if inv_panel:
			next_top = inv_panel.global_position.y + inv_panel.size.y + PANEL_GAP
		else:
			next_top = INV_TOP + INV_HEIGHT + PANEL_GAP

	if stats_visible:
		_set_panel_position(stats_ui, next_top)
		next_top += PANEL_HEIGHT + PANEL_GAP

	if skills_visible:
		_set_panel_position(skills_ui, next_top)

func _set_panel_position(ui_node, top: float) -> void:
	var panel = ui_node.get_node_or_null("Panel")
	if not panel:
		return
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 0.0
	panel.offset_left = INV_LEFT
	panel.offset_top = top
	panel.offset_right = INV_RIGHT
	panel.offset_bottom = top + PANEL_HEIGHT
