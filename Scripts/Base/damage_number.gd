extends Node2D

func show_damage(amount: int, pos: Vector2) -> void:
	global_position = pos

	var label := Label.new()
	label.text = str(amount)
	label.add_theme_color_override("font_color", Color(1, 0.85, 0, 1))  # amarillo
	label.add_theme_font_size_override("font_size", 16)
	label.position = Vector2(-10, -20)

	# sombra para legibilidad
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)

	add_child(label)

	# flotar hacia arriba y desaparecer
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 30, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.chain().tween_callback(queue_free)
