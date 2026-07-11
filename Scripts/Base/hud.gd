extends CanvasLayer

@onready var health_bar: ProgressBar = $Panel/VBoxContainer/HealthBar
@onready var sp_bar: ProgressBar = $Panel/VBoxContainer/SPBar
@onready var exp_label: Label = $Panel/VBoxContainer/ExpLabel
@onready var class_exp_label: Label = $Panel/VBoxContainer/ClassExpLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Stats.stats_changed.connect(_refresh_exp)
	Stats.level_up.connect(func(_l): _refresh_exp())
	Stats.class_level_up.connect(func(_l): _refresh_exp())
	_refresh_exp()

func setup(player: Player) -> void:
	player.health_component.health_changed.connect(_on_health_changed)
	player.sp_changed.connect(_on_sp_changed)
	health_bar.max_value = player.health_component.max_health
	health_bar.value = player.health_component.current_health
	sp_bar.max_value = player.max_sp
	sp_bar.value = player.current_sp
	_refresh_exp()

func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current

func _on_sp_changed(current: int, maximum: int) -> void:
	sp_bar.max_value = maximum
	sp_bar.value = current

func _refresh_exp() -> void:
	if exp_label:
		exp_label.text = "Nv " + str(Stats.base_level) + "  EXP: " + str(Stats.base_exp) + " / " + str(Stats.base_exp_to_next)
	if class_exp_label:
		class_exp_label.text = "Clase " + str(Stats.class_level) + "  EXP: " + str(Stats.class_exp) + " / " + str(Stats.class_exp_to_next)
