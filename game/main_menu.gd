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

@onready var press_start = $Title
@onready var mode_select = $ModeSelect


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

	show_press_start()
	$Title/HoldButtonTutorial.intro_complete.connect(_on_intro_done)

func _on_intro_done():
	show_mode_select()

func show_press_start():
	press_start.visible = true
	mode_select.visible = false

func show_mode_select():
	press_start.visible = false
	mode_select.visible = true
