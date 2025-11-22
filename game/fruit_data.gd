class_name FruitData
extends Resource

@export var name: String = ""
@export var texture: Texture2D
@export var static_body: bool = false
@export var smooth_tween: bool = false

func _init(
	_name: String = "",
	_texture: Texture2D = null,
	_static_body: bool = false,
	_smooth_tween: bool = false
):
	name = _name
	texture = _texture
	static_body = _static_body
	smooth_tween = _smooth_tween
