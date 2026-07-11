extends CanvasLayer

func _ready() -> void:
	# pausar el juego al aparecer
	get_tree().paused = true
	# asegurarse que esta escena siga funcionando aunque el juego esté pausado
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_button_pressed() -> void:
	get_tree().paused = false
	queue_free()
	get_tree().reload_current_scene()
