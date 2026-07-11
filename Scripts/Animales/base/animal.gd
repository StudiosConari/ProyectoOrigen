extends CharacterBody2D

const DamageNumber = preload("res://Scripts/base/damage_number.gd")
const WorldDrop = preload("res://Scenes/world_drop.tscn")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: HealthComponent = $Components/HealthComponent

enum State { PATROL, PASTURE, FLEE, DEAD }
var current_state: State = State.PATROL

# patrol
@export var patrol_points: Array[Vector2] = []
@export var patrol_speed := 40.0
var patrol_index := 0
var patrol_wait_timer := 0.0
@export var patrol_wait_time := 2.0

# pasture
var pasture_timer := 0.0

# flee
@export var flee_radius := 100.0
@export var flee_speed := 90.0

# respawn
@export var respawn_time := 30.0

var player: Player
var is_dead := false
var spawn_position: Vector2
var knockback_force := 200.0
var knockback_duration := 0.15
var _knockback_velocity := Vector2.ZERO
var _knockback_timer := 0.0

func _ready() -> void:
	spawn_position = global_position
	health.death.connect(_on_death)
	_setup()
	if patrol_points.is_empty():
		current_state = State.PASTURE
		sprite.play("pastando")
		_pick_pasture_timer()
	else:
		sprite.play("run")

# override en subclases para definir stats
func _setup() -> void:
	pass

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return

	if not player:
		player = get_tree().get_first_node_in_group("player")

	# huir si el jugador está cerca
	if player and current_state != State.FLEE:
		var dist := global_position.distance_to(player.global_position)
		if dist < flee_radius:
			current_state = State.FLEE

	# dejar de huir si el jugador se alejó
	if current_state == State.FLEE and player:
		var dist := global_position.distance_to(player.global_position)
		if dist >= flee_radius:
			current_state = State.PATROL if not patrol_points.is_empty() else State.PASTURE
			if current_state == State.PASTURE:
				_pick_pasture_timer()

	# aplicar knockback
	if _knockback_timer > 0.0:
		velocity = _knockback_velocity
		_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, knockback_force / knockback_duration * delta)
		_knockback_timer -= delta
		move_and_slide()
		return

	match current_state:
		State.PATROL:
			_do_patrol(delta)
		State.PASTURE:
			_do_pasture(delta)
		State.FLEE:
			_do_flee()

func _do_patrol(delta: float) -> void:
	if patrol_points.is_empty():
		current_state = State.PASTURE
		return

	if patrol_wait_timer > 0.0:
		sprite.play("pastando")
		velocity = Vector2.ZERO
		patrol_wait_timer -= delta
		if patrol_wait_timer <= 0.0:
			patrol_index = (patrol_index + 1) % patrol_points.size()
		move_and_slide()
		return

	var target := patrol_points[patrol_index]
	var dir := (target - global_position)
	var dist := dir.length()

	if dist <= 8.0:
		patrol_wait_timer = patrol_wait_time
		sprite.play("pastando")
		velocity = Vector2.ZERO
	else:
		sprite.play("run")
		velocity = dir.normalized() * patrol_speed
		if velocity.x != 0:
			sprite.flip_h = velocity.x < 0

	move_and_slide()

func _do_pasture(delta: float) -> void:
	sprite.play("pastando")
	velocity = Vector2.ZERO
	pasture_timer -= delta
	if pasture_timer <= 0.0:
		if not patrol_points.is_empty():
			current_state = State.PATROL
		else:
			_pick_pasture_timer()
	move_and_slide()

func _do_flee() -> void:
	if not player:
		return
	sprite.play("run")
	var flee_dir := (global_position - player.global_position).normalized()
	velocity = flee_dir * flee_speed
	sprite.flip_h = velocity.x < 0
	move_and_slide()

func receive_damage(amount: int) -> void:
	if is_dead:
		return
	_show_damage_number(amount)
	health.receive_damage(amount)
	# knockback
	if player:
		var direction := (global_position - player.global_position).normalized()
		_knockback_velocity = direction * knockback_force
		_knockback_timer = knockback_duration
	_flash_damage()

func _flash_damage() -> void:
	sprite.modulate = Color(1.5, 0.3, 0.3, 1)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)

func _show_damage_number(amount: int) -> void:
	var dmg := Node2D.new()
	var script := load("res://Scripts/base/damage_number.gd")
	dmg.set_script(script)
	get_tree().current_scene.add_child(dmg)
	dmg.show_damage(amount, global_position + Vector2(0, -20))

func _on_death() -> void:
	if is_dead:
		return
	is_dead = true
	current_state = State.DEAD
	set_physics_process(false)
	# esperar a que terminen flash y knockback antes de desaparecer
	_flash_damage()
	await get_tree().create_timer(0.25).timeout
	visible = false
	var drops := _drop_loot()
	_spawn_drops(drops)
	await get_tree().create_timer(respawn_time).timeout
	_respawn()

func _spawn_drops(drops: Array) -> void:
	for drop in drops:
		var instance = WorldDrop.instantiate()
		instance.item_type = drop.type
		instance.quantity = drop.quantity
		instance.position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		get_tree().current_scene.add_child(instance)

# override en subclases para definir el loot — debe retornar Array
func _drop_loot() -> Array:
	return []

func _respawn() -> void:
	health.current_health = health.max_health
	health.update_health_bar()
	global_position = spawn_position
	patrol_index = 0
	is_dead = false
	visible = true
	set_physics_process(true)
	if patrol_points.is_empty():
		current_state = State.PASTURE
		_pick_pasture_timer()
		sprite.play("pastando")
	else:
		current_state = State.PATROL
		sprite.play("run")

# override en subclases para definir el loot


func _pick_pasture_timer() -> void:
	pasture_timer = randf_range(3.0, 7.0)
