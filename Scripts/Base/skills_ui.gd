extends CanvasLayer

@onready var panel: Panel = $Panel

var _built := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	add_to_group("skills_ui")
	Stats.stats_changed.connect(_refresh)
	Stats.skill_points_changed.connect(func(_p): _refresh())

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_H:
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
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "HABILIDADES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.3, 1))
	vbox.add_child(title)

	var pts := Label.new()
	pts.name = "SkillPoints"
	pts.text = "Puntos disponibles: 0"
	pts.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pts.add_theme_color_override("font_color", Color(0.3, 0.8, 1, 1))
	vbox.add_child(pts)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	# una fila por habilidad
	for key in Stats.skills:
		_build_skill_row(vbox, key)

func _build_skill_row(parent: VBoxContainer, skill_key: String) -> void:
	var skill = Stats.skills[skill_key]
	var container := VBoxContainer.new()
	container.name = "Skill_" + skill_key
	container.add_theme_constant_override("separation", 4)
	parent.add_child(container)

	var name_label := Label.new()
	name_label.name = "Name"
	name_label.text = skill.name
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3, 1))
	container.add_child(name_label)

	var info_label := Label.new()
	info_label.name = "Info"
	info_label.add_theme_font_size_override("font_size", 12)
	info_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
	container.add_child(info_label)

	var hbox := HBoxContainer.new()
	hbox.name = "HBox"
	hbox.add_theme_constant_override("separation", 8)
	container.add_child(hbox)

	var level_label := Label.new()
	level_label.name = "Level"
	level_label.add_theme_font_size_override("font_size", 12)
	level_label.add_theme_color_override("font_color", Color(0.6, 0.9, 0.6, 1))
	hbox.add_child(level_label)

	var btn := Button.new()
	btn.name = "UpgradeBtn"
	btn.text = "▲ Subir"
	btn.add_theme_font_size_override("font_size", 12)
	btn.pressed.connect(func(): _on_upgrade(skill_key))
	hbox.add_child(btn)

func _on_upgrade(skill_key: String) -> void:
	Stats.upgrade_skill(skill_key)

func _refresh() -> void:
	if not _built:
		return
	var vbox := panel.get_node_or_null("VBox")
	if not vbox:
		return

	vbox.get_node("SkillPoints").text = "Puntos disponibles: " + str(Stats.skill_points)

	for key in Stats.skills:
		var skill = Stats.skills[key]
		var row = vbox.get_node_or_null("Skill_" + key)
		if not row:
			continue
		var dmg := Stats.get_skill_damage(key)
		row.get_node("Info").text = skill.description + "\nDaño: " + str(dmg) + " (+25% por nivel)"
		row.get_node("HBox/Level").text = "Nivel " + str(skill.level) + " / " + str(skill.max_level)
		var btn = row.get_node("HBox/UpgradeBtn")
		btn.disabled = Stats.skill_points <= 0 or skill.level >= skill.max_level
		if skill.level >= skill.max_level:
			btn.text = "MAX"
