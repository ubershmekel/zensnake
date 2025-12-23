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

@export var fruit_data: FruitData:
	set(value):
		fruit_data = value
		_apply_fruit_data()

var _eat_tween: Tween = null

func _ready():
	# Connect the area_entered signal to our function
	self.area_entered.connect(_on_area_entered)
	# In the editor the tool script can run before the static dictionary is ready, so pull it here.
	if not fruit_data:
		push_warning("fruit_data is empty; fruit visuals will not preview.")
		return
	
	_apply_fruit_data()

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
	
func random_position():
	var viewport_size = get_viewport().get_visible_rect().size
	var x_tiles = int(floor(viewport_size.x / TILE_SIZE))
	var y_tiles = int(floor(viewport_size.y / TILE_SIZE))
	var random_x = randi_range(1, x_tiles - 1)
	# y starts at 2 to avoid the iphone's dynamic island
	var random_y = randi_range(2, y_tiles - 1)
	position = Vector2(random_x * TILE_SIZE, random_y * TILE_SIZE)
	z_index = 100
