extends Node

const FRUIT_COUNT := 20
const FALL_SPEED := 40.0

@onready var _fruit_scene: PackedScene = preload("res://game/fruit.tscn")
@onready var _grape_data: FruitData = preload("res://resources/fruit/grapes.tres")

var _fruits: Array[FruitClass] = []

func _ready() -> void:
	randomize()
	var parent := get_parent()
	if parent == null:
		push_warning("FruitRainManager has no parent to attach fruits to.")
		return
	var viewport_size := get_viewport().get_visible_rect().size
	for i in range(FRUIT_COUNT):
		var fruit: FruitClass = _fruit_scene.instantiate()
		fruit.fruit_data = _grape_data
		fruit.position = Vector2(randf_range(0.0, viewport_size.x), randf_range(0.0, viewport_size.y))
		parent.add_child(fruit)
		_fruits.append(fruit)

func _process(delta: float) -> void:
	if _fruits.is_empty():
		return
	var viewport_size := get_viewport().get_visible_rect().size
	for fruit in _fruits:
		if not is_instance_valid(fruit):
			# Fruit gets freed when eaten
			continue
		var pos := fruit.position
		pos.y += FALL_SPEED * delta
		if pos.y > viewport_size.y:
			pos.y = - FruitClass.TILE_SIZE
			pos.x = randf_range(0.0, viewport_size.x)
		fruit.position = pos
