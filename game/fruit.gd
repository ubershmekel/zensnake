@tool
extends Area2D
class_name FruitClass

# Emit which snake (Node) ate the apple so the correct snake can react, along with the effect to apply
signal eaten(snake, fruit_data: FruitData)
signal eaten_animation_done(fruit: FruitClass)

const TILE_SIZE = 32

@onready var sprite: Sprite2D = $Sprite2D
@onready var _base_scale: Vector2 = sprite.scale

@export var fruit_types: FruitList = preload("res://resources/fruits_list_all.tres")
@export var shyness_velocity: float = 0.0
@export var fall_speed: float = 0.0

@export var fruit_data: FruitData:
	set(value):
		fruit_data = value
		_apply_fruit_data()

var _eat_tween: Tween = null
var _wiggle_time := 0.0

func _ready():
	# Connect the area_entered signal to our function
	self.area_entered.connect(_on_area_entered)
	# In the editor the tool script can run before the static dictionary is ready, so pull it here.
	if not fruit_data:
		push_warning("fruit_data is empty; fruit visuals will not preview.")
		return
	
	_apply_fruit_data()

func _physics_process(delta: float) -> void:
	if shyness_velocity > 0.0:
		_shyness_physics_process(delta)
	
	if fall_speed > 0.0:
		_fall_physics_process(delta)
	
func _fall_physics_process(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	position.y += fall_speed * delta
	if position.y > viewport_size.y:
		position.y = - FruitClass.TILE_SIZE


func _shyness_physics_process(delta: float) -> void:
	var snake = _get_closest_snake()
	if not is_instance_valid(snake):
		return
	var snake_pos = snake.global_position
	if snake.has_method("get_head_pos"):
		snake_pos = snake.get_head_pos()
	var away = global_position - snake_pos
	var distance = away.length()
	if distance == 0.0:
		return
	const FULL_SPEED_DISTANCE := 150.0
	const NO_EFFECT_DISTANCE := 400.0
	var shy_percent = clamp((NO_EFFECT_DISTANCE - distance) / (NO_EFFECT_DISTANCE - FULL_SPEED_DISTANCE), 0.0, 1.0)
	var speed = shyness_velocity * shy_percent
	_apply_wiggle(delta, shy_percent)
	if speed <= 0.0:
		return
	global_position += away / distance * speed * delta
	_clamp_to_screen()

func _get_closest_snake() -> Node2D:
	var snakes = get_tree().get_nodes_in_group("snakes")
	if snakes.is_empty():
		return null
	var closest: Node2D = null
	var closest_dist_sq := INF
	for snake in snakes:
		if not is_instance_valid(snake):
			continue
		var snake_pos = snake.get_head_pos()
		var dist_sq = global_position.distance_squared_to(snake_pos)
		if dist_sq < closest_dist_sq:
			closest_dist_sq = dist_sq
			closest = snake
	return closest

func _apply_wiggle(delta: float, shy_percent: float) -> void:
	if _eat_tween:
		return
	const WIGGLE_SPEED := 10.0
	const WIGGLE_ANGLE := .58
	var _wiggle_amount = max(0.1, shy_percent) * delta
	_wiggle_time += _wiggle_amount * WIGGLE_SPEED
	sprite.rotation = sin(_wiggle_time) * WIGGLE_ANGLE

func _clamp_to_screen() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	const EDGE_BUFFER := 50.0
	global_position.x = clamp(global_position.x, EDGE_BUFFER, viewport_size.x - EDGE_BUFFER)
	global_position.y = clamp(global_position.y, EDGE_BUFFER, viewport_size.y - EDGE_BUFFER)

func _apply_fruit_data():
	if not fruit_data:
		push_warning("Invalid fruit_data")
		return
	_update_fruit_display()

func _on_area_entered(area):
	# We only care if the area that entered is the snake's head
	if area.name == 'SnakeHead':
		# The head Area2D is a child of the snake Node2D instance.
		# Emit the parent snake so the game can call the correct snake's grow method.
		var snake = area.get_parent()
		emit_signal("eaten", snake, fruit_data)
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
	_eat_tween.tween_callback(after_eaten)

func _reset_visual_state():
	sprite.scale = _base_scale
	sprite.modulate = Color.WHITE
	sprite.rotation = 0

func _update_fruit_display():
	if sprite:
		# button_pressed -> play -> load("res://game/game.tscn").instantiate()
		# sets the fruit type but the sprite isn't loaded yet
		sprite.texture = fruit_data.texture

func after_eaten():
	if _eat_tween:
		_eat_tween.kill()
		_eat_tween = null
	_reset_visual_state()
	# detect collisions
	set_deferred("monitoring", true)
	emit_signal("eaten_animation_done", self)

func random_type():
	if fruit_types:
		var random_index = randi() % fruit_types.fruits.size()
		var random_fruit: FruitData = fruit_types.fruits[random_index]
		fruit_data = random_fruit
		sprite.texture = random_fruit.texture
		return fruit_data
	
func random_position():
	var viewport_size = get_viewport().get_visible_rect().size
	var x_tiles = int(floor(viewport_size.x / TILE_SIZE))
	var y_tiles = int(floor(viewport_size.y / TILE_SIZE))
	var random_x = randi_range(1, x_tiles - 1)
	# y starts at 2 to avoid the iphone's dynamic island
	var random_y = randi_range(2, y_tiles - 1)
	position = Vector2(random_x * TILE_SIZE, random_y * TILE_SIZE)
	z_index = 100
