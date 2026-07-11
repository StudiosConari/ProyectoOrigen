class_name ItemData extends Resource

enum Type {
	LANZA_COMPLETA,
	FRAGMENTO_ARMA,
	CASCO,
	PECHERA,
	PANTALONES,
	BOTAS,
	GUANTES,
	FRAGMENTO_ARMADURA,
	MONEDAS,
	NUCLEO_LANCERO,
	ESPIRITU_LANCERO,
	ANILLO,
	COLLAR,
	CINTURON,
	LANA,
	CARNE,
	ESPIRITU_OVEJA,
	POCION_VIDA,
	POCION_SP,
	AROS,
	MASCOTA
}

@export var item_type: Type
@export var item_name: String
@export var quantity: int = 1
@export var icon: Texture2D

# Estadísticas que otorga este item al equiparse
# { ataque_fisico, ataque_distancia, ataque_magico, defensa_fisica, defensa_distancia, defensa_magica }
static func get_stats(t: int) -> Dictionary:
	match t:
		Type.LANZA_COMPLETA:
			return { "ataque_fisico": 8, "ataque_distancia": 0, "ataque_magico": 0, "defensa_fisica": 0, "defensa_distancia": 0, "defensa_magica": 0 }
		Type.FRAGMENTO_ARMA:
			return { "ataque_fisico": 3, "ataque_distancia": 0, "ataque_magico": 0, "defensa_fisica": 0, "defensa_distancia": 0, "defensa_magica": 0 }
		Type.CASCO:
			return { "ataque_fisico": 0, "ataque_distancia": 0, "ataque_magico": 0, "defensa_fisica": 4, "defensa_distancia": 2, "defensa_magica": 2 }
		Type.PECHERA:
			return { "ataque_fisico": 0, "ataque_distancia": 0, "ataque_magico": 0, "defensa_fisica": 6, "defensa_distancia": 3, "defensa_magica": 3 }
		Type.PANTALONES:
			return { "ataque_fisico": 0, "ataque_distancia": 0, "ataque_magico": 0, "defensa_fisica": 4, "defensa_distancia": 2, "defensa_magica": 2 }
		Type.BOTAS:
			return { "ataque_fisico": 0, "ataque_distancia": 0, "ataque_magico": 0, "defensa_fisica": 2, "defensa_distancia": 2, "defensa_magica": 0 }
		Type.GUANTES:
			return { "ataque_fisico": 2, "ataque_distancia": 0, "ataque_magico": 0, "defensa_fisica": 2, "defensa_distancia": 0, "defensa_magica": 0 }
		Type.FRAGMENTO_ARMADURA:
			return { "ataque_fisico": 0, "ataque_distancia": 0, "ataque_magico": 0, "defensa_fisica": 2, "defensa_distancia": 1, "defensa_magica": 1 }
		Type.ANILLO:
			return { "ataque_fisico": 2, "ataque_distancia": 2, "ataque_magico": 2, "defensa_fisica": 0, "defensa_distancia": 0, "defensa_magica": 0 }
		Type.COLLAR:
			return { "ataque_fisico": 0, "ataque_distancia": 0, "ataque_magico": 4, "defensa_fisica": 0, "defensa_distancia": 0, "defensa_magica": 4 }
		Type.CINTURON:
			return { "ataque_fisico": 0, "ataque_distancia": 0, "ataque_magico": 0, "defensa_fisica": 2, "defensa_distancia": 2, "defensa_magica": 2 }
		Type.AROS:
			return { "ataque_fisico": 0, "ataque_distancia": 3, "ataque_magico": 3, "defensa_fisica": 0, "defensa_distancia": 0, "defensa_magica": 0 }
		_:
			return { "ataque_fisico": 0, "ataque_distancia": 0, "ataque_magico": 0, "defensa_fisica": 0, "defensa_distancia": 0, "defensa_magica": 0 }

static func get_texture(t: int) -> Texture2D:
	match t:
		Type.LANZA_COMPLETA:
			return load("res://Assets/Icons/weapons/lanza_completa.png")
		Type.FRAGMENTO_ARMA:
			return load("res://Assets/Icons/weapons/fragmento_arma.png")
		Type.CASCO:
			return load("res://Assets/Icons/armor/casco.png")
		Type.PECHERA:
			return load("res://Assets/Icons/armor/pechera.png")
		Type.PANTALONES:
			return load("res://Assets/Icons/armor/pantalones.png")
		Type.BOTAS:
			return load("res://Assets/Icons/armor/botas.png")
		Type.GUANTES:
			return load("res://Assets/Icons/armor/guantes.png")
		Type.FRAGMENTO_ARMADURA:
			return load("res://Assets/Icons/armor/fragmento_armadura.png")
		Type.NUCLEO_LANCERO:
			return load("res://Assets/Icons/special/nucleo_lancero.png")
		Type.ESPIRITU_LANCERO:
			return load("res://Assets/Icons/special/espiritu_lancero.png")
		Type.ANILLO:
			return load("res://Assets/Icons/accessories/anillo.png")
		Type.COLLAR:
			return load("res://Assets/Icons/accessories/collar.png")
		Type.CINTURON:
			return load("res://Assets/Icons/accessories/cinturon.png")
		Type.MONEDAS:
			return load("res://Assets/Icons/resources/coin.png")
		Type.LANA:
			return load("res://Assets/Icons/resources/lana.png")
		Type.CARNE:
			return load("res://Assets/Icons/resources/carne.png")
		Type.ESPIRITU_OVEJA:
			return load("res://Assets/Icons/special/espiritu_oveja.png")
		Type.AROS:
			return load("res://Assets/Icons/accessories/aros.png")
		Type.MASCOTA:
			return load("res://Assets/Icons/pets/mascota.png")
		Type.POCION_VIDA:
			return load("res://Assets/Icons/consumables/pocion_vida.png")
		Type.POCION_SP:
			return load("res://Assets/Icons/consumables/pocion_sp.png")
		_:
			return null
