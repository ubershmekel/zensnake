extends Resource
class_name SnakeEffect

# Encapsulates all effects that can be applied to a snake
@export var growth_amount: int = 1
@export var static_body: bool = false
@export var smooth_tween: bool = false
@export var speed_factor: float = 1.0

func _init(growth: int = 0, is_static: bool = false, is_smooth: bool = false):
	growth_amount = growth
	static_body = is_static
	smooth_tween = is_smooth
