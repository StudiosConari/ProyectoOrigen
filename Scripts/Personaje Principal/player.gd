class_name Player extends CharacterBody2D

const Item = preload("res://Scripts/Mecanicas/item.gd")

signal attack_finished
signal lives_changed(lives: int)
signal sp_changed(current: int, maximum: int)

@onready var sprite_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $Components/HealthComponent

var move_speed := 200
var _base_attack_damage := 50
var attack_damage: int:
	get: return _base_attack_damage + Stats.get_physical_bonus()
var special_damage: int:
	get: return Stats.get_skill_damage("golpe_especial") + Stats.get_physical_bonus()
var special_sp_cost := 20
var is_special_attack := false
var _last_attack_damage := 50

var current_attack_damage: int:
	get:
		return _last_attack_damage
var is_attack := false
var is_invincible := false
var is_dead := false
var invincible_duration := 0.6

@export var max_sp := 50
@export var pocion_vida_amount := 30
@export var pocion_sp_amount := 20
var current_sp := 50
@export var sp_regen_percent := 10.0
@export var sp_regen_interval := 4.0
var _sp_regen_timer := 0.0
@export var hp_regen_percent := 5.0
@export var hp_regen_interval := 4.0
var _hp_regen_timer := 0.0

@export var max_lives := 3
@export var respawn_time := 3.0
@export var respawn_position: Vector2
@export var height_level := 0

var current_lives := 3

# cuerpos dentro del área de ataque que pueden recibir daño
var _bodies_in_range: Array = []

func _ready() -> void:
	add_to_group("player")
	health_component.death.connect(on_death)
	respawn_position = global_position

func _input(event: InputEvent) -> void:
	var inventory_ui = get_tree().get_first_node_in_group("inventory_ui")
	if inventory_ui and inventory_ui.visible:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				attack()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				special_attack()
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			_use_action_bar_item()

func _physics_process(_delta: float) -> void:
	var inventory_ui = get_tree().get_first_node_in_group("inventory_ui")
	if inventory_ui and inventory_ui.visible:
		velocity = Vector2.ZERO
		sprite_animation.play("idle")
		move_and_slide()
		return
	if !is_attack:
		var move_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if move_direction:
			velocity = move_direction * move_speed
			sprite_animation.play("run")
			if move_direction.x != 0:
				sprite_animation.flip_h = move_direction.x < 0
				$AreaAttack.scale.x = -1 if move_direction.x < 0 else 1
		else:
			velocity = velocity.move_toward(Vector2.ZERO, move_speed)
			sprite_animation.play("idle")
		move_and_slide()

func _process(delta: float) -> void:
	if not is_dead:
		# regenerar SP
		if current_sp < max_sp:
			_sp_regen_timer += delta
			if _sp_regen_timer >= sp_regen_interval:
				_sp_regen_timer = 0.0
				var regen := int(max_sp * sp_regen_percent / 100.0)
				restore_sp(regen)
		# regenerar HP
		if health_component.current_health < health_component.max_health:
			_hp_regen_timer += delta
			if _hp_regen_timer >= hp_regen_interval:
				_hp_regen_timer = 0.0
				var regen := int(health_component.max_health * hp_regen_percent / 100.0)
				health_component.heal(regen)

func attack() -> void:
	sprite_animation.play("attack")
	is_attack = true

func special_attack() -> void:
	if is_attack:
		return
	if not use_sp(special_sp_cost):
		return  # sin SP suficiente
	is_special_attack = true
	sprite_animation.play("special")
	is_attack = true

func _use_action_bar_item() -> void:
	var action_bar = get_tree().get_first_node_in_group("action_bar")
	if not action_bar:
		return
	var item = action_bar.get_selected_item()
	if not item:
		return
	match item.type:
		Item.Type.POCION_VIDA:
			health_component.heal(pocion_vida_amount)
			_consume_action_bar_item(action_bar)
		Item.Type.POCION_SP:
			restore_sp(pocion_sp_amount)
			_consume_action_bar_item(action_bar)

func _consume_action_bar_item(action_bar) -> void:
	var slot_index: int = action_bar.get_selected_slot()
	var item = Inventory.get_action_bar_slot(slot_index)
	if item.quantity > 1:
		item.quantity -= 1
		Inventory.set_action_bar_slot(slot_index, item)
	else:
		Inventory.set_action_bar_slot(slot_index, null)

func receive_damage(amount: int) -> void:
	receive_physical_damage(amount)

func receive_physical_damage(amount: int) -> void:
	if is_invincible or is_dead:
		return
	var reduced := Stats.get_defense_reduction(amount)
	health_component.receive_damage(reduced)

func receive_ranged_damage(amount: int) -> void:
	if is_invincible or is_dead:
		return
	var reduced := Stats.get_ranged_defense_reduction(amount)
	health_component.receive_damage(reduced)

func receive_magic_damage(amount: int) -> void:
	if is_invincible or is_dead:
		return
	var reduced := Stats.get_magic_defense_reduction(amount)
	health_component.receive_damage(reduced)
	is_invincible = true
	_blink()
	await get_tree().create_timer(invincible_duration).timeout
	if !is_dead:
		is_invincible = false
		sprite_animation.modulate = Color.WHITE

func use_sp(amount: int) -> bool:
	if current_sp < amount:
		return false
	current_sp = clamp(current_sp - amount, 0, max_sp)
	sp_changed.emit(current_sp, max_sp)
	return true

func restore_sp(amount: int) -> void:
	current_sp = clamp(current_sp + amount, 0, max_sp)
	sp_changed.emit(current_sp, max_sp)

func _blink() -> void:
	var tween := create_tween().set_loops(5)
	tween.tween_property(sprite_animation, "modulate", Color(1, 1, 1, 0.2), 0.05)
	tween.tween_property(sprite_animation, "modulate", Color.WHITE, 0.05)

func on_death() -> void:
	if is_dead:
		return
	is_dead = true
	is_attack = false
	is_invincible = true
	visible = false
	set_physics_process(false)
	set_process_input(false)
	current_lives -= 1
	lives_changed.emit(current_lives)
	if current_lives <= 0:
		_game_over()
		return
	await get_tree().create_timer(respawn_time).timeout
	_respawn()

func _respawn() -> void:
	health_component.current_health = health_component.max_health
	health_component.update_health_bar()
	health_component.health_changed.emit(health_component.current_health, health_component.max_health)
	current_sp = max_sp
	sp_changed.emit(current_sp, max_sp)
	global_position = respawn_position
	height_level = 0
	is_dead = false
	is_attack = false
	is_special_attack = false
	is_invincible = false
	visible = true
	set_physics_process(true)
	set_process_input(true)
	sprite_animation.modulate = Color.WHITE
	sprite_animation.play("idle")

func _game_over() -> void:
	var game_over_scene = preload("res://Scenes/game_over.tscn")
	get_tree().root.add_child(game_over_scene.instantiate())

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite_animation.animation == "attack" or sprite_animation.animation == "special":
		is_attack = false
		var damage := special_damage if is_special_attack else attack_damage
		is_special_attack = false
		for body in _bodies_in_range:
			if is_instance_valid(body) and body.has_method("receive_damage"):
				body.receive_damage(damage)
		_last_attack_damage = damage
		attack_finished.emit()

func _on_area_attack_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.in_attack_player_range = true
	if body.has_method("receive_damage") and not _bodies_in_range.has(body):
		_bodies_in_range.append(body)

func _on_area_attack_body_exited(body: Node2D) -> void:
	if body is Enemy:
		body.in_attack_player_range = false
	_bodies_in_range.erase(body)
