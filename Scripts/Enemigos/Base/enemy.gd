class_name Enemy extends CharacterBody2D

@onready var sprite_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: HealthComponent = $Components/HealthComponent
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

const Item = preload("res://Scripts/Mecanicas/item.gd")
const DamageNumber = preload("res://Scripts/base/damage_number.gd")
const WorldDrop = preload("res://Scenes/world_drop.tscn")

var move_speed := 100
var attack_damage := 10
var exp_reward := 0
var class_exp_reward := 0
var knockback_force := 300.0
var knockback_duration := 0.15
var _knockback_velocity := Vector2.ZERO
var _knockback_timer := 0.0
var player: Player
var in_attack_player_range := false
var is_dead := false

enum State { IDLE, CHASE, ATTACK, DEAD, RETURN }
var current_state: State = State.IDLE

@export var detection_range := 200.0
@export var attack_range := 60.0
@export var respawn_time := 10.0
@export var height_level := 0
@export var hear_range := 80.0
@export var max_chase_distance := 300.0

var spawn_position: Vector2
var spawn_height_level: int = 0
var loot_table: LootTable
var attack_cooldown := 0.0
var _attack_cooldown_timer := 0.0

func _ready() -> void:
	spawn_position = global_position
	health.death.connect(on_death)
	_setup()
	spawn_height_level = height_level

func _setup() -> void:
	pass

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	if !player:
		player = get_tree().get_first_node_in_group("player")
		if player:
			player.attack_finished.connect(verify_recieve_damage)
		return

	# si el player está muerto, volver al spawn y esperar
	if player.is_dead:
		if current_state != State.RETURN:
			current_state = State.RETURN
		_state_return()
		return

	# cooldown de ataque
	if _attack_cooldown_timer > 0.0:
		_attack_cooldown_timer -= delta

	# aplicar knockback
	if _knockback_timer > 0.0:
		velocity = _knockback_velocity
		_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, knockback_force / knockback_duration * delta)
		_knockback_timer -= delta
		move_and_slide()
		return

	var distance := position.distance_to(player.position)
	var distance_from_spawn := position.distance_to(spawn_position)

	match current_state:
		State.IDLE:
			if distance <= detection_range:
				current_state = State.CHASE
		State.CHASE:
			if distance_from_spawn >= max_chase_distance:
				current_state = State.RETURN
			elif distance <= attack_range:
				current_state = State.ATTACK
			elif distance > detection_range:
				current_state = State.IDLE
		State.ATTACK:
			if distance > attack_range:
				current_state = State.CHASE
		State.RETURN:
			if position.distance_to(spawn_position) <= 10:
				height_level = spawn_height_level
				current_state = State.IDLE

	match current_state:
		State.IDLE:
			_state_idle()
		State.CHASE:
			_state_chase()
		State.ATTACK:
			_state_attack()
		State.RETURN:
			_state_return()

func _state_idle() -> void:
	sprite_animation.play("idle")
	velocity = Vector2.ZERO
	move_and_slide()

func _state_chase() -> void:
	sprite_animation.play("run")
	nav_agent.target_position = player.global_position
	var next_pos := nav_agent.get_next_path_position()
	var move_direction := (next_pos - global_position).normalized()
	velocity = move_direction * move_speed
	if move_direction.x != 0:
		sprite_animation.flip_h = move_direction.x < 0
		$AreaAttack.scale.x = -1 if move_direction.x < 0 else 1
	move_and_slide()

func _state_attack() -> void:
	velocity = Vector2.ZERO
	if player and player.height_level == height_level:
		if _attack_cooldown_timer <= 0.0 and sprite_animation.animation != "attack":
			sprite_animation.play("attack")
	elif player:
		current_state = State.CHASE

func _state_return() -> void:
	sprite_animation.play("run")
	nav_agent.target_position = spawn_position
	var next_pos := nav_agent.get_next_path_position()
	var move_direction := (next_pos - global_position).normalized()
	velocity = move_direction * move_speed
	if move_direction.x != 0:
		sprite_animation.flip_h = move_direction.x < 0
		$AreaAttack.scale.x = -1 if move_direction.x < 0 else 1
	move_and_slide()

func verify_recieve_damage() -> void:
	if not player:
		return
	var distance := position.distance_to(player.position)
	if distance <= attack_range:
		var dmg := player.current_attack_damage
		health.receive_damage(dmg)
		_show_damage_number(dmg)
		var direction := (global_position - player.global_position).normalized()
		_knockback_velocity = direction * knockback_force
		_knockback_timer = knockback_duration
		_flash_damage()

func _flash_damage() -> void:
	sprite_animation.modulate = Color(1.5, 0.3, 0.3, 1)
	var tween := create_tween()
	tween.tween_property(sprite_animation, "modulate", Color.WHITE, 0.2)

func _show_damage_number(amount: int) -> void:
	var dmg = Node2D.new()
	dmg.set_script(DamageNumber)
	get_tree().current_scene.add_child(dmg)
	dmg.show_damage(amount, global_position + Vector2(0, -20))

func on_death() -> void:
	if is_dead:
		return
	is_dead = true
	current_state = State.DEAD
	set_physics_process(false)
	if player and player.attack_finished.is_connected(verify_recieve_damage):
		player.attack_finished.disconnect(verify_recieve_damage)
	if exp_reward > 0:
		Stats.add_base_exp(exp_reward)
	if class_exp_reward > 0:
		Stats.add_class_exp(class_exp_reward)
	_flash_damage()
	await get_tree().create_timer(0.25).timeout
	visible = false
	$CollisionShape2D.disabled = true
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	# limpiar referencia en el player
	if player and "_bodies_in_range" in player:
		player._bodies_in_range.erase(self)
	if loot_table:
		var drops = loot_table.roll()
		_spawn_drops(drops)
	await get_tree().create_timer(respawn_time).timeout
	_respawn()

func _spawn_drops(drops: Array) -> void:
	var offset := Vector2.ZERO
	for drop in drops:
		var instance = WorldDrop.instantiate()
		instance.item_type = drop.type
		instance.quantity = drop.quantity
		# esparcir drops alrededor del enemigo
		offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		instance.position = global_position + offset
		get_tree().current_scene.add_child(instance)

func _respawn() -> void:
	health.current_health = health.max_health
	health.update_health_bar()
	global_position = spawn_position
	height_level = spawn_height_level
	current_state = State.IDLE
	is_dead = false
	visible = true
	$CollisionShape2D.disabled = false
	if player and not player.attack_finished.is_connected(verify_recieve_damage):
		player.attack_finished.connect(verify_recieve_damage)
	set_deferred("collision_layer", 1)
	set_deferred("collision_mask", 1)
	set_physics_process(true)
	sprite_animation.play("idle")

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite_animation.animation == "attack":
		if not player or player.is_dead:
			sprite_animation.play("idle")
			current_state = State.IDLE
			return
		if player.height_level == height_level:
			var distance := position.distance_to(player.position)
			if distance <= attack_range:
				player.receive_physical_damage(attack_damage)
		_attack_cooldown_timer = attack_cooldown
		sprite_animation.play("idle")

func _on_area_attack_body_entered(_body: Node2D) -> void:
	pass

func _on_area_attack_body_exited(_body: Node2D) -> void:
	pass
