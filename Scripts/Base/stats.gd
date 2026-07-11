extends Node

signal stats_changed
signal level_up(new_level: int)
signal class_level_up(new_level: int)
signal skill_points_changed(points: int)
signal stat_points_changed(points: int)

# Nivel base
var base_level := 1
var base_exp := 0
var base_exp_to_next: int:
	get: return base_level * 100

# Nivel de clase
var class_level := 1
var class_exp := 0
var class_exp_to_next: int:
	get: return class_level * 100

# Puntos disponibles
var skill_points := 0
var stat_points := 0

# Estadísticas primarias (máx 100 cada una)
const STAT_MAX := 100
const STAT_POINTS_PER_LEVEL := 7
var fuerza := 1
var destreza := 1
var inteligencia := 1

# Estadísticas base derivadas (nivel 1 = 4 cada una)
var _base_ataque_fisico := 4
var _base_ataque_distancia := 4
var _base_ataque_magico := 4
var _base_defensa_fisica := 4
var _base_defensa_distancia := 4
var _base_defensa_magica := 4

# Bonus por equipo
var _equip_ataque_fisico := 0
var _equip_ataque_distancia := 0
var _equip_ataque_magico := 0
var _equip_defensa_fisica := 0
var _equip_defensa_distancia := 0
var _equip_defensa_magica := 0

# Stats totales (base + equipo + primarias)
var ataque_fisico: int:
	get: return _base_ataque_fisico + _equip_ataque_fisico + (fuerza - 1) * 2
var ataque_distancia: int:
	get: return _base_ataque_distancia + _equip_ataque_distancia + (destreza - 1) * 2
var ataque_magico: int:
	get: return _base_ataque_magico + _equip_ataque_magico + (inteligencia - 1) * 2
var defensa_fisica: int:
	get: return _base_defensa_fisica + _equip_defensa_fisica
var defensa_distancia: int:
	get: return _base_defensa_distancia + _equip_defensa_distancia
var defensa_magica: int:
	get: return _base_defensa_magica + _equip_defensa_magica

# Habilidades
var skills := {
	"golpe_especial": {
		"name": "Golpe Especial",
		"level": 1,
		"max_level": 10,
		"base_damage": 100,
		"description": "Golpe poderoso con click derecho"
	}
}

func add_base_exp(amount: int) -> void:
	base_exp += amount
	while base_exp >= base_exp_to_next:
		base_exp -= base_exp_to_next
		_level_up_base()
	stats_changed.emit()

func add_class_exp(amount: int) -> void:
	class_exp += amount
	while class_exp >= class_exp_to_next:
		class_exp -= class_exp_to_next
		_level_up_class()
	stats_changed.emit()

func _level_up_base() -> void:
	base_level += 1
	# +2 a todas las defensas base
	_base_defensa_fisica += 2
	_base_defensa_distancia += 2
	_base_defensa_magica += 2
	# otorgar puntos de estadística
	stat_points += STAT_POINTS_PER_LEVEL
	stat_points_changed.emit(stat_points)
	level_up.emit(base_level)
	stats_changed.emit()

func _level_up_class() -> void:
	class_level += 1
	skill_points += 1
	class_level_up.emit(class_level)
	skill_points_changed.emit(skill_points)
	stats_changed.emit()

func increase_stat(stat: String) -> bool:
	if stat_points <= 0:
		return false
	match stat:
		"fuerza":
			if fuerza >= STAT_MAX:
				return false
			fuerza += 1
		"destreza":
			if destreza >= STAT_MAX:
				return false
			destreza += 1
		"inteligencia":
			if inteligencia >= STAT_MAX:
				return false
			inteligencia += 1
		_:
			return false
	stat_points -= 1
	stat_points_changed.emit(stat_points)
	stats_changed.emit()
	return true

func upgrade_skill(skill_key: String) -> bool:
	if skill_points <= 0:
		return false
	var skill = skills.get(skill_key)
	if not skill:
		return false
	if skill.level >= skill.max_level:
		return false
	skill.level += 1
	skill_points -= 1
	skill_points_changed.emit(skill_points)
	stats_changed.emit()
	return true

func get_skill_damage(skill_key: String) -> int:
	var skill = skills.get(skill_key)
	if not skill:
		return 0
	var multiplier: float = 1.0 + (skill.level - 1) * 0.25
	return int(skill.base_damage * multiplier)

func get_physical_bonus() -> int:
	return int((ataque_fisico - 4) * 0.5)

func get_ranged_bonus() -> int:
	return int((ataque_distancia - 4) * 0.5)

func get_magic_bonus() -> int:
	return int((ataque_magico - 4) * 0.5)

func get_defense_reduction(incoming: int) -> int:
	var reduction := int(defensa_fisica * 0.5)
	return max(1, incoming - reduction)

func get_ranged_defense_reduction(incoming: int) -> int:
	var reduction := int(defensa_distancia * 0.5)
	return max(1, incoming - reduction)

func get_magic_defense_reduction(incoming: int) -> int:
	var reduction := int(defensa_magica * 0.5)
	return max(1, incoming - reduction)

func apply_equipment_stats(item_type: int) -> void:
	var s = ItemData.get_stats(item_type)
	_equip_ataque_fisico += s.ataque_fisico
	_equip_ataque_distancia += s.ataque_distancia
	_equip_ataque_magico += s.ataque_magico
	_equip_defensa_fisica += s.defensa_fisica
	_equip_defensa_distancia += s.defensa_distancia
	_equip_defensa_magica += s.defensa_magica
	stats_changed.emit()

func remove_equipment_stats(item_type: int) -> void:
	var s = ItemData.get_stats(item_type)
	_equip_ataque_fisico -= s.ataque_fisico
	_equip_ataque_distancia -= s.ataque_distancia
	_equip_ataque_magico -= s.ataque_magico
	_equip_defensa_fisica -= s.defensa_fisica
	_equip_defensa_distancia -= s.defensa_distancia
	_equip_defensa_magica -= s.defensa_magica
	stats_changed.emit()
