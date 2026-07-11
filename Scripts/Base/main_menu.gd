extends CanvasLayer

@onready var btn_play: Button = $CenterContainer/VBoxContainer/BtnPlay
@onready var btn_options: Button = $CenterContainer/VBoxContainer/BtnOptions
@onready var btn_quit: Button = $CenterContainer/VBoxContainer/BtnQuit
@onready var options_panel: Panel = $OptionsPanel
@onready var btn_close_options: Button = $OptionsPanel/VBoxContainer/BtnClose

func _ready() -> void:
	btn_play.pressed.connect(_on_play)
	btn_options.pressed.connect(_on_options)
	btn_quit.pressed.connect(_on_quit)
	btn_close_options.pressed.connect(_on_close_options)
	options_panel.visible = false

func _on_play() -> void:
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_options() -> void:
	options_panel.visible = true

func _on_close_options() -> void:
	options_panel.visible = false

func _on_quit() -> void:
	get_tree().quit()
