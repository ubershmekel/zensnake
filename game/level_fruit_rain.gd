extends LevelBase

const FRUIT_COUNT := 20
const FALL_SPEED := 40.0

@onready var _fruit_scene: PackedScene = preload("res://game/fruit.tscn")
@onready var _grape_data: FruitData = preload("res://resources/fruit/grapes.tres")

var fruit_spawned_count := 0;
var fruit_eaten_count := 0;

func _spawn_fruit():
	var fruit: FruitClass = _fruit_scene.instantiate()
	fruit.fruit_data = _grape_data
	# Parent may still be configuring its children, so defer attaching the fruit.
	add_child(fruit)
	fruit.eaten.connect(_on_fruit_eaten)
	fruit.eaten_animation_done.connect(_on_fruit_eaten_animation_done)
	return fruit

func _on_fruit_eaten(eater: Node, fruit_data: FruitData) -> void:
	fruit_eaten_count += 1
	# Emit signal so game can react to fruit being eaten
	fruit_eaten.emit(eater, fruit_data)

func _on_fruit_eaten_animation_done(fruit: FruitClass) -> void:
	# Instead of respawning the fruit like fruit_randomizer does,
	# we delete it to complete the "eat all fruit" level objective
	fruit.queue_free()
	
	# Check if all fruits have been eaten
	if fruit_eaten_count == fruit_spawned_count:
		level_done.emit()


var _fruits: Array[FruitClass] = []

func _ready() -> void:
	randomize()
	var parent := get_parent()
	if parent == null:
		push_warning("FruitRainManager has no parent to attach fruits to.")
		return
	var viewport_size := get_viewport().get_visible_rect().size
	

	for i in range(FRUIT_COUNT):
		fruit_spawned_count += 1
		var fruit: FruitClass = _spawn_fruit()
		fruit.position = Vector2(randf_range(0.0, viewport_size.x), randf_range(0.0, viewport_size.y))
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
