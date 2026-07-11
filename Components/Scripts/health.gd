class_name HealthComponent extends Node2D

signal death
signal health_changed(current: int, maximum: int)

@export var progress_bar: ProgressBar
@export var current_health := 100
@export var max_health := 100

func _ready() -> void:
	update_health_bar()

func update_health_bar() -> void:
	if progress_bar:
		progress_bar.value = current_health

func receive_damage(amount: int) -> void:
	current_health = clamp(current_health - amount, 0, max_health)
	update_health_bar()
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		on_death()

func heal(amount: int) -> void:
	current_health = clamp(current_health + amount, 0, max_health)
	update_health_bar()
	health_changed.emit(current_health, max_health)

func on_death() -> void:
	death.emit()
