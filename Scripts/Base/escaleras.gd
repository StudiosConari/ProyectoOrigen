extends Area2D

@export var floor_alto := 1
@export var floor_bajo := 0

var area_center_y := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# calcular el centro real del polígono de colisión
	await get_tree().process_frame
	var polygon = get_node_or_null("CollisionPolygon2D")
	if polygon:
		var points = polygon.polygon
		var min_y = points[0].y
		var max_y = points[0].y
		for p in points:
			if p.y < min_y:
				min_y = p.y
			if p.y > max_y:
				max_y = p.y
		# convertir a coordenadas globales
		area_center_y = polygon.global_position.y + (min_y + max_y) / 2.0

func _on_body_entered(body: Node2D) -> void:
	if not (body is Player or body is Enemy):
		return
	if body.global_position.y > area_center_y:
		body.height_level = floor_alto
	else:
		body.height_level = floor_bajo

func _on_body_exited(body: Node2D) -> void:
	if not (body is Player or body is Enemy):
		return
	if body.global_position.y < area_center_y:
		body.height_level = floor_alto
	else:
		body.height_level = floor_bajo
