extends CanvasLayer

@onready var panel: Panel = $Panel
var _built := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	add_to_group("stats_ui")
	Stats.stats_changed.connect(_refresh)
	Stats.stat_points_changed.connect(func(_p): _refresh())

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_C:
			visible = !visible
			if visible and not _built:
				_build_ui()
				_built = true
			if visible:
				_refresh()
			var _ui_mgr = get_node_or_null("/root/UiManager")
			if _ui_mgr:
				_ui_mgr.notify_visibility_changed()

func _build_ui() -> void:
	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	# título
	var title := Label.new()
	title.text = "ESTADÍSTICAS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.3, 1))
	vbox.add_child(title)

	# puntos de estadística disponibles
	var sep2 := HSeparator.new()
	vbox.add_child(sep2)
	var pts_label := Label.new()
	pts_label.name = "stat_points"
	pts_label.add_theme_font_size_override("font_size", 13)
	pts_label.add_theme_color_override("font_color", Color(0.3, 0.8, 1, 1))
	vbox.add_child(pts_label)

	# estadísticas primarias con botones
	var sep3 := HSeparator.new()
	vbox.add_child(sep3)
	_add_primary_stat(vbox, "fuerza", "Fuerza", "fuerza")
	_add_primary_stat(vbox, "destreza", "Destreza", "destreza")
	_add_primary_stat(vbox, "inteligencia", "Inteligencia", "inteligencia")

	# estadísticas derivadas
	var sep4 := HSeparator.new()
	vbox.add_child(sep4)
	_add_label(vbox, "atk_fis", "Ataque Físico: 4 (+0 daño)")
	_add_label(vbox, "atk_dis", "Ataque a Distancia: 4 (+0 daño)")
	_add_label(vbox, "atk_mag", "Ataque Mágico: 4 (+0 daño)")
	_add_label(vbox, "def_fis", "Defensa Física: 4 (-2 daño)")
	_add_label(vbox, "def_dis", "Defensa a Distancia: 4 (-2 daño)")
	_add_label(vbox, "def_mag", "Defensa Mágica: 4 (-2 daño)")

func _add_label(parent: VBoxContainer, node_name: String, text: String) -> void:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1))
	parent.add_child(label)

func _add_primary_stat(parent: VBoxContainer, node_name: String, _label_text: String, stat_key: String) -> void:
	var hbox := HBoxContainer.new()
	hbox.name = node_name + "_row"
	hbox.add_theme_constant_override("separation", 6)
	parent.add_child(hbox)

	var lbl := Label.new()
	lbl.name = node_name + "_lbl"
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.3, 1))
	hbox.add_child(lbl)

	var btn := Button.new()
	btn.name = node_name + "_btn"
	btn.text = "+"
	btn.custom_minimum_size = Vector2(24, 20)
	btn.add_theme_font_size_override("font_size", 12)
	btn.pressed.connect(func(): Stats.increase_stat(stat_key))
	hbox.add_child(btn)

func _refresh() -> void:
	if not _built:
		return
	var vbox := panel.get_node_or_null("VBox")
	if not vbox:
		return

	vbox.get_node("stat_points").text = "Puntos de Estadística: " + str(Stats.stat_points)

	# primarias
	_refresh_primary(vbox, "fuerza", "Fuerza", Stats.fuerza)
	_refresh_primary(vbox, "destreza", "Destreza", Stats.destreza)
	_refresh_primary(vbox, "inteligencia", "Inteligencia", Stats.inteligencia)

	# derivadas
	vbox.get_node("atk_fis").text = "Ataque Físico: " + str(Stats.ataque_fisico) + " (+" + str(Stats.get_physical_bonus()) + " daño)"
	vbox.get_node("atk_dis").text = "Ataque a Distancia: " + str(Stats.ataque_distancia) + " (+" + str(Stats.get_ranged_bonus()) + " daño)"
	vbox.get_node("atk_mag").text = "Ataque Mágico: " + str(Stats.ataque_magico) + " (+" + str(Stats.get_magic_bonus()) + " daño)"
	vbox.get_node("def_fis").text = "Defensa Física: " + str(Stats.defensa_fisica) + " (-" + str(int(Stats.defensa_fisica * 0.5)) + " daño)"
	vbox.get_node("def_dis").text = "Defensa a Distancia: " + str(Stats.defensa_distancia) + " (-" + str(int(Stats.defensa_distancia * 0.5)) + " daño)"
	vbox.get_node("def_mag").text = "Defensa Mágica: " + str(Stats.defensa_magica) + " (-" + str(int(Stats.defensa_magica * 0.5)) + " daño)"

func _refresh_primary(vbox: VBoxContainer, node_name: String, label_text: String, value: int) -> void:
	var row = vbox.get_node_or_null(node_name + "_row")
	if not row:
		return
	var lbl = row.get_node(node_name + "_lbl")
	lbl.text = label_text + ": " + str(value) + " / " + str(Stats.STAT_MAX)
	var btn = row.get_node(node_name + "_btn")
	btn.disabled = Stats.stat_points <= 0 or value >= Stats.STAT_MAX
