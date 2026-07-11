extends CanvasLayer

const ItemScript = preload("res://Scripts/Mecanicas/item.gd")

var _panel: Panel
var _label: RichTextLabel

# Descripciones de cada item
const DESCRIPTIONS = {
	ItemData.Type.LANZA_COMPLETA:     "Lanza forjada en acero. Arma principal de los lanceros.",
	ItemData.Type.FRAGMENTO_ARMA:     "Fragmento de un arma rota. Podría usarse para reforzar.",
	ItemData.Type.CASCO:              "Casco de batalla. Protege la cabeza de golpes físicos.",
	ItemData.Type.PECHERA:            "Pechera de metal. La mejor protección para el torso.",
	ItemData.Type.PANTALONES:         "Pantalones acorazados. Protegen las piernas en combate.",
	ItemData.Type.BOTAS:              "Botas reforzadas. Protegen los pies y mejoran la movilidad.",
	ItemData.Type.GUANTES:            "Guantes de combate. Mejoran el agarre y el golpe físico.",
	ItemData.Type.FRAGMENTO_ARMADURA: "Fragmento de armadura dañada. Aún ofrece algo de protección.",
	ItemData.Type.ANILLO:             "Anillo mágico. Potencia el ataque en todas sus formas.",
	ItemData.Type.COLLAR:             "Collar encantado. Amplifica el poder mágico y la defensa.",
	ItemData.Type.CINTURON:           "Cinturón resistente. Otorga protección balanceada.",
	ItemData.Type.AROS:               "Aros místicos. Potencian el ataque a distancia y mágico.",
	ItemData.Type.MONEDAS:            "Monedas de oro. La moneda del reino.",
	ItemData.Type.LANA:               "Lana suave de oveja. Material de artesanía.",
	ItemData.Type.CARNE:              "Carne fresca de oveja. Podría usarse para recuperarse.",
	ItemData.Type.NUCLEO_LANCERO:     "Núcleo de energía de un lancero caído.",
	ItemData.Type.ESPIRITU_LANCERO:   "Espíritu de un lancero. Puede imbuirse en equipo.",
	ItemData.Type.ESPIRITU_OVEJA:     "Espíritu de oveja. Emana una energía tranquila.",
	ItemData.Type.POCION_VIDA:        "Poción de vida. Restaura 30 HP al usarse con E.",
	ItemData.Type.POCION_SP:          "Poción de SP. Restaura 20 SP al usarse con E.",
	ItemData.Type.MASCOTA:            "Una fiel mascota que te acompaña en la aventura.",
}

func _ready() -> void:
	layer = 100
	_build_panel()

func _build_panel() -> void:
	_panel = Panel.new()
	_panel.visible = false
	_panel.custom_minimum_size = Vector2(200, 60)
	_panel.z_index = 100

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.1, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.6, 0.5, 0.2, 1)
	style.content_margin_left = 8
	style.content_margin_top = 6
	style.content_margin_right = 8
	style.content_margin_bottom = 6
	_panel.add_theme_stylebox_override("panel", style)

	_label = RichTextLabel.new()
	_label.bbcode_enabled = true
	_label.fit_content = true
	_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_label.add_theme_font_size_override("normal_font_size", 12)
	_panel.add_child(_label)
	add_child(_panel)

func show_tooltip(item_type: int, mouse_pos: Vector2) -> void:
	var text := _build_text(item_type)
	if text.is_empty():
		return
	_label.text = text
	# ajustar tamaño al contenido
	await get_tree().process_frame
	var size := _label.get_content_height()
	_panel.custom_minimum_size.y = size + 20
	# posicionar cerca del mouse sin salirse de pantalla
	var vp := get_viewport().get_visible_rect().size
	var pos := mouse_pos + Vector2(12, 12)
	if pos.x + 210 > vp.x:
		pos.x = mouse_pos.x - 210
	if pos.y + _panel.custom_minimum_size.y > vp.y:
		pos.y = mouse_pos.y - _panel.custom_minimum_size.y
	_panel.position = pos
	_panel.visible = true

func hide_tooltip() -> void:
	_panel.visible = false

func _build_text(item_type: int) -> String:
	var item_name: String = _get_name(item_type)
	if item_name.is_empty():
		return ""

	var desc: String = DESCRIPTIONS.get(item_type, "")
	var stats: Dictionary = ItemData.get_stats(item_type)

	var text := "[b][color=#ffd966]" + item_name + "[/color][/b]\n"
	if not desc.is_empty():
		text += "[color=#cccccc]" + desc + "[/color]\n"

	# mostrar solo stats que no sean 0
	var has_stats := false
	for key in stats:
		if stats[key] != 0:
			has_stats = true
			break

	if has_stats:
		text += "\n[color=#aaffaa]Estadísticas:[/color]\n"
		const STAT_NAMES = {
			"ataque_fisico": "Ataque Físico",
			"ataque_distancia": "Ataque a Distancia",
			"ataque_magico": "Ataque Mágico",
			"defensa_fisica": "Defensa Física",
			"defensa_distancia": "Defensa a Distancia",
			"defensa_magica": "Defensa Mágica",
		}
		for key in stats:
			if stats[key] != 0:
				var prefix := "+" if stats[key] > 0 else ""
				text += "[color=#88ff88]  " + STAT_NAMES[key] + ": " + prefix + str(stats[key]) + "[/color]\n"

	return text

func _get_name(item_type: int) -> String:
	match item_type:
		ItemData.Type.LANZA_COMPLETA:     return "Lanza Completa"
		ItemData.Type.FRAGMENTO_ARMA:     return "Fragmento de Arma"
		ItemData.Type.CASCO:              return "Casco"
		ItemData.Type.PECHERA:            return "Pechera"
		ItemData.Type.PANTALONES:         return "Pantalones"
		ItemData.Type.BOTAS:              return "Botas"
		ItemData.Type.GUANTES:            return "Guantes"
		ItemData.Type.FRAGMENTO_ARMADURA: return "Fragmento de Armadura"
		ItemData.Type.ANILLO:             return "Anillo"
		ItemData.Type.COLLAR:             return "Collar"
		ItemData.Type.CINTURON:           return "Cinturón"
		ItemData.Type.AROS:               return "Aros"
		ItemData.Type.MONEDAS:            return "Monedas"
		ItemData.Type.LANA:               return "Lana"
		ItemData.Type.CARNE:              return "Carne"
		ItemData.Type.NUCLEO_LANCERO:     return "Núcleo del Lancero"
		ItemData.Type.ESPIRITU_LANCERO:   return "Espíritu del Lancero"
		ItemData.Type.ESPIRITU_OVEJA:     return "Espíritu de Oveja"
		ItemData.Type.POCION_VIDA:        return "Poción de Vida"
		ItemData.Type.POCION_SP:          return "Poción de SP"
		ItemData.Type.MASCOTA:            return "Mascota"
		_: return ""
