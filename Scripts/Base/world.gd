extends Node2D

@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		hud.setup(player)
	# pociones iniciales
	Inventory.add_item(ItemData.Type.POCION_VIDA, 2)
	Inventory.add_item(ItemData.Type.POCION_SP, 2)
