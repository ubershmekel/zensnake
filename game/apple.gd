@tool
extends Area2D

# Emit which snake (Node) ate the apple so the correct snake can react, along with the effect to apply
signal eaten(snake, fruit: FruitData)

const TILE_SIZE = 32

@onready var sprite: Sprite2D = $Sprite2D
@onready var _base_scale: Vector2 = sprite.scale

@export_enum("Apple", "Banana", "Cherries", "Chili", "Grapes", "Orange", "Watermelon")
var fruit_type_selection: String = "Apple":
	set(value):
		fruit_type_selection = value
		print("	Selected fruit type: %s" % fruit_type_selection)
		_update_fruit_display()

var fruits: Array[FruitData] = [
	FruitData.new(
		"apple",
		preload("res://assets/eat/apple.png"),
		false,
		false
	),
	FruitData.new(
		"banana",
		preload("res://assets/eat/banana.png"),
		false,
		true
	),
	FruitData.new(
		"cherries",
		preload("res://assets/eat/cherries.png"),
		true,
		false
	),
	FruitData.new(
		"chili",
		preload("res://assets/eat/chili.png"),
		true,
		true
	),
	FruitData.new(
		"grapes",
		preload("res://assets/eat/grapes.png"),
		false,
		false
	),
	FruitData.new(
		"orange",
		preload("res://assets/eat/orange.png"),
		false,
		true
	),
	FruitData.new(
		"watermelon",
		preload("res://assets/eat/waterm.png"),
		true,
		false
	),
]

var _current_fruit: FruitData = null
var _eat_tween: Tween = null

func _ready():
	# Connect the area_entered signal to our function
	self.area_entered.connect(_on_area_entered)
	_update_fruit_display()
	reposition()

func _on_area_entered(area):
	# We only care if the area that entered is the snake's head
	if area.name == 'SnakeHead':
		# The head Area2D is a child of the snake Node2D instance.
		# Emit the parent snake so the game can call the correct snake's grow method.
		var snake = area.get_parent()
		emit_signal("eaten", snake, _current_fruit)
		_play_eaten_animation()

func _play_eaten_animation():
	# Quick pop-and-fade so eating feels rewarding
	if _eat_tween:
		_eat_tween.kill()
	_reset_visual_state()
	# do not detect collisions during animation
	set_deferred("monitoring", false)
	const duration = 0.4
	var pop_scale = _base_scale * .35
	var spin = deg_to_rad(randi_range(60, 180))
	_eat_tween = create_tween()
	_eat_tween.tween_property(sprite, "scale", pop_scale, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_eat_tween.parallel().tween_property(sprite, "modulate:a", 0.0, duration)
	_eat_tween.parallel().tween_property(sprite, "rotation", spin, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_eat_tween.tween_callback(reposition)

func _reset_visual_state():
	sprite.scale = _base_scale
	sprite.modulate = Color.WHITE
	sprite.rotation = 0

func _update_fruit_display():
	var selected_fruit_data: FruitData = null
	for fruit in fruits:
		if fruit.name.to_lower() == fruit_type_selection.to_lower():
			selected_fruit_data = fruit
			break

	if selected_fruit_data:
		_current_fruit = selected_fruit_data
		sprite.texture = _current_fruit.texture

func reposition():
	if _eat_tween:
		_eat_tween.kill()
		_eat_tween = null
	_reset_visual_state()
	# detect collisions
	set_deferred("monitoring", true)
	randomize()
	if fruits.size() > 0:
		var random_index = randi() % fruits.size()
		_current_fruit = fruits[random_index]
		sprite.texture = _current_fruit.texture

	var viewport_size = get_viewport().get_visible_rect().size
	var x_tiles = int(floor(viewport_size.x / TILE_SIZE))
	var y_tiles = int(floor(viewport_size.y / TILE_SIZE))
	var random_x = randi_range(1, x_tiles - 1)
	# y starts at 2 to avoid the iphone's dynamic island
	var random_y = randi_range(2, y_tiles - 1)
	position = Vector2(random_x * TILE_SIZE, random_y * TILE_SIZE)
	z_index = 100
