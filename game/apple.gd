extends Area2D

# Emit which snake (Node) ate the apple so the correct snake can react
signal eaten(snake)

const TILE_SIZE = 32

@export var textures: Array[Texture2D] = [
	preload("res://assets/eat/apple.png"),
	preload("res://assets/eat/banana.png"),
	preload("res://assets/eat/cherries.png"),
	preload("res://assets/eat/chili.png"),
	preload("res://assets/eat/grapes.png"),
	preload("res://assets/eat/orange.png"),
	preload("res://assets/eat/waterm.png"),
]

func _ready():
	# Connect the area_entered signal to our function
	self.area_entered.connect(_on_area_entered)
	reposition()

func _on_area_entered(area):
	# We only care if the area that entered is the snake's head
	if area.name == 'SnakeHead':
		# The head Area2D is a child of the snake Node2D instance.
		# Emit the parent snake so the game can call the correct snake's grow method.
		var snake = area.get_parent()
		emit_signal("eaten", snake)
		reposition()

func reposition():
	randomize()
	if textures.size() > 0:
		$Sprite2D.texture = textures[randi() % textures.size()]

	var viewport_size = get_viewport().get_visible_rect().size
	var x_tiles = int(floor(viewport_size.x / TILE_SIZE))
	var y_tiles = int(floor(viewport_size.y / TILE_SIZE))
	var random_x = randi_range(1, x_tiles - 1)
	var random_y = randi_range(1, y_tiles - 1)
	position = Vector2(random_x * TILE_SIZE, random_y * TILE_SIZE)
	z_index = 10
