extends Node2D

const HOLD_TO_START_DURATION := 1.0

signal intro_complete()
@onready var hold_button: Button = $HoldButton
@onready var intro_snake: Node2D = $IntroSnake

var _intro_hold_time := 0.0
var _intro_hold_active := false
var _intro_complete := false

func _ready():
	hold_button.button_down.connect(_on_hold_button_down)
	hold_button.button_up.connect(_on_hold_button_up)
	_intro_complete = false
	_set_intro_hold(false)


func _process(delta: float) -> void:
	#if press_start.visible and not _intro_complete:
	if _intro_hold_active:
		_intro_hold_time += delta
		if _intro_hold_time >= HOLD_TO_START_DURATION:
			_complete_intro()
	else:
		_intro_hold_time = 0.0

func _input(event):
	#if not press_start.visible:
		#return
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
	#show_mode_select()
	emit_signal("intro_complete")
