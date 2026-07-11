extends Node2D

const ItemScript = preload("res://Scripts/Mecanicas/item.gd")

var item_type: int = -1
var quantity: int = 1
var _collected := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var area: Area2D = $Area2D

func _ready() -> void:
	if item_type == -1:
		return
	# asignar textura
	var texture = ItemScript.get_texture(item_type)
	sprite.texture = texture

	# mostrar cantidad si es más de 1
	if quantity > 1:
		label.text = "x" + str(quantity)
	else:
		label.text = ""

	# animación: flotar hacia arriba y desaparecer después de 8 segundos
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 20, 0.5).set_ease(Tween.EASE_OUT)
	tween.chain().tween_interval(6.0)
	tween.chain().tween_property(self, "modulate:a", 0.0, 1.5)
	tween.chain().tween_callback(queue_free)

	# detectar si el player lo recoge
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _collected:
		return
	if body is Player:
		_collected = true
		Inventory.add_item(item_type, quantity)
		# mostrar en drop log
		var drop_log = get_tree().get_first_node_in_group("drop_log")
		if drop_log:
			drop_log.show_drops([{ "type": item_type, "quantity": quantity }])
		queue_free()
