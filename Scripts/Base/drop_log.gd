extends CanvasLayer

@onready var container: VBoxContainer = $Container

const ItemScript = preload("res://Scripts/Mecanicas/item.gd")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_drops(drops: Array) -> void:
	for drop in drops:
		if drop.type == ItemScript.Type.MONEDAS:
			_add_entry("+ " + str(drop.quantity) + " Monedas")
		else:
			var item_name = ItemScript.Type.keys()[drop.type]
			var text = "+ " + item_name.capitalize().replace("_", " ")
			if drop.quantity > 1:
				text += " x" + str(drop.quantity)
			_add_entry(text)

func _add_entry(text: String) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(1, 0.85, 0, 1))  # amarillo
	label.add_theme_font_size_override("font_size", 14)
	
	# fondo transparente
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.4)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", style)
	panel.add_child(label)
	
	container.add_child(panel)
	
	# fade out
	var tween = create_tween()
	tween.tween_interval(10.0)
	tween.tween_property(panel, "modulate:a", 0.0, 5.0)
	tween.tween_callback(panel.queue_free)
