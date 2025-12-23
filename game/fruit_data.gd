extends Resource
class_name FruitData

@export var key: String = ""
@export var texture: Texture2D
@export var snake_effect: SnakeEffect

func _init(
	_key: String = "",
	_texture: Texture2D = null,
	_snake_effect: SnakeEffect = null
):
	key = _key
	texture = _texture
	snake_effect = _snake_effect if _snake_effect else SnakeEffect.new()
