extends Node2D

func _on_button_2p_pressed() -> void:
	play(2)

func _on_button_1p_pressed() -> void:
	play(1)

func play(playerCount: int) -> void:
	var next_scene = load("res://game/game.tscn").instantiate()
	next_scene.player_count = playerCount
	get_tree().root.add_child(next_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = next_scene

const HOLD_TO_START_DURATION := 1.0

@onready var press_start = $Title
@onready var mode_select = $ModeSelect
@onready var hold_button: Button = $Title/HoldButton
@onready var intro_snake: Node2D = $Title/IntroSnake

var _intro_hold_time := 0.0
var _intro_hold_active := false
var _intro_complete := false

func device_is_touch() -> bool:
	# is_touchscreen_available is true on web and PC for some reason
	# DisplayServer.is_touchscreen_available()
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		return true
	else:
		return false


func _ready():
	if device_is_touch():
		$Title/Instructions1p.text = "For 1 player tap and hold anywhere on the screen to turn left"
		$Title/Instructions2p.text = "For 2 players, the left and right edges of the screen are the turn left button"

	hold_button.button_down.connect(_on_hold_button_down)
	hold_button.button_up.connect(_on_hold_button_up)
	show_press_start()

func show_press_start():
	_intro_complete = false
	_set_intro_hold(false)
	press_start.visible = true
	mode_select.visible = false

func show_mode_select():
	press_start.visible = false
	mode_select.visible = true

func _process(delta: float) -> void:
	if press_start.visible and not _intro_complete:
		if _intro_hold_active:
			_intro_hold_time += delta
			if _intro_hold_time >= HOLD_TO_START_DURATION:
				_complete_intro()
		else:
			_intro_hold_time = 0.0

func _input(event):
	if not press_start.visible:
		return

	if event.is_action_pressed("ui_accept"):
		_set_intro_hold(true)
	elif event.is_action_released("ui_accept"):
		_set_intro_hold(false)

func _on_hold_button_down() -> void:
	_set_intro_hold(true)

func _on_hold_button_up() -> void:
	_set_intro_hold(false)

func _set_intro_hold(active: bool) -> void:
	_intro_hold_active = active
	if intro_snake and intro_snake.has_method("set_turning_left"):
		intro_snake.set_turning_left(active)
	if not active:
		_intro_hold_time = 0.0

func _complete_intro() -> void:
	if _intro_complete:
		return
	_intro_complete = true
	_set_intro_hold(false)
	show_mode_select()
