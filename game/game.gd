extends Node2D

@export var levels: Array[PackedScene]

@onready var bottom_button := $UI/TwoPlayerButtons/BottomButton
@onready var top_button := $UI/TwoPlayerButtons/TopButton
@onready var full_screen_button := $UI/FullScreenButton
@onready var two_player_buttons := $UI/TwoPlayerButtons

# player_count gets overwritten by the buttons in the main menu
var player_count = 1
var snakes = []
var level_index := 0
var level: LevelBase

const SKIN_SNAKE: String = "snake"
const SKIN_CATERPY: String = "caterpy"
const SKINS: Array[String] = [SKIN_SNAKE, SKIN_CATERPY]
const LEVEL_RESET_POSITION := Vector2(100, 100)
const LEVEL_RESET_ANIMATION_TIME := 1.45
const LEVEL_RESET_HORIZONTAL_SPACING := 120

func _ready():
	$Snake.position.x = 0
	$Snake.position.y = 0
	_load_level(0)
	
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
		two_player_buttons.visible = true
	else:
		full_screen_button.visible = true
		two_player_buttons.visible = false


func _load_level(i: int) -> void:
	if is_instance_valid(level):
		level.queue_free()

	level_index = i
	level = levels[level_index].instantiate() as LevelBase
	$LevelSlot.add_child(level)

	# Connect level events (per instance)
	level.fruit_eaten.connect(_on_fruit_eaten)
	level.level_done.connect(_on_level_done)

func _on_level_done():
	print("level done")

	var base_position := LEVEL_RESET_POSITION
	for i in range(snakes.size()):
		var snake = snakes[i]
		if not is_instance_valid(snake):
			continue
		var offset := Vector2(LEVEL_RESET_HORIZONTAL_SPACING * i, 0)
		if snake.has_method("reset_for_new_level"):
			await snake.reset_for_new_level(base_position + offset, 2, LEVEL_RESET_ANIMATION_TIME)

	level_index = (level_index + 1) % levels.size()
	_load_level(level_index)
	

func _on_fruit_eaten(eater: Node, fruit_data: FruitData = null):
	# Handle growth logic here to avoid duplication and allow level-specific behavior
	if eater and eater.has_method("_on_snake_effect"):
		# Get the snake effect from fruit data and set level-specific growth
		var snake_effect = fruit_data.snake_effect if fruit_data else SnakeEffect.new()
		snake_effect.growth_amount = level.growth_per_fruit
		# Apply the effect to the appropriate snake
		eater._on_snake_effect(snake_effect)

# The top controls the first snake
# The bottom controls the last snake
# When there is only one snake that means it's just the 1
func _process(_delta) -> void:
	if snakes.size() == 2:
		snakes[0].is_button_down = top_button.is_down
		snakes[1].is_button_down = bottom_button.is_down
	else:
		snakes[0].is_button_down = full_screen_button.is_pressed()


func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	$UI/PauseMenu.visible = true
