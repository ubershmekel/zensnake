extends Node2D

@onready var bottom_button := $CanvasLayer/GridContainer/BottomButton
@onready var top_button := $CanvasLayer/GridContainer/TopButton
@onready var full_screen_button := $CanvasLayer/FullScreenButton

# player_count gets overwritten by the buttons in the main menu
var player_count = 1
var snakes = []

const SKIN_SNAKE: String = "snake"
const SKIN_CATERPY: String = "caterpy"
const SKINS: Array[String] = [SKIN_SNAKE, SKIN_CATERPY]

func _ready():
	$Snake.position.x = 0
	$Snake.position.y = 0
	# Connect the apple's "eaten" signal to our local handler so we can forward
	# the event to the specific snake instance that ate the apple.
	$Apple.eaten.connect(_on_apple_eaten)
	$Apple.reposition()
	snakes = [$Snake]

	# Apply textures to the primary snake
	if player_count == 1:
		randomize()
		var skin: String = SKINS[randi() % SKINS.size()]
		$Snake.load_skin(skin)
	else:
		$Snake.load_skin(SKIN_SNAKE)
	
	if player_count == 2:
		var new_snake = $Snake.duplicate()
		add_child(new_snake)
		new_snake.hotkey = KEY_B
		# Assign caterpy textures to the duplicated second-player snake
		# Load the caterpy skin on the new snake (not the original)
		new_snake.load_skin(SKIN_CATERPY)
		snakes.append(new_snake)

		# disable fullscreen button
		full_screen_button.visible = false
		bottom_button.visible = true
		top_button.visible = true
	else:
		full_screen_button.visible = true
		bottom_button.visible = false
		top_button.visible = false


func _on_apple_eaten(snake, fruit: FruitData = null):
	# Forward the eaten event to the snake instance that ate the apple.
	# We call its handler so the proper snake grows.
	if snake and snake.has_method("_on_apple_eaten"):
		snake._on_apple_eaten(fruit)

# The top controls the first snake
# The bottom controls the last snake
# When there is only one snake that means it's just the 1
func _process(_delta) -> void:
	if snakes.size() == 2:
		snakes[0].is_button_down = top_button.is_pressed()
		snakes[1].is_button_down = bottom_button.is_pressed()
	else:
		snakes[0].is_button_down = full_screen_button.is_pressed()
