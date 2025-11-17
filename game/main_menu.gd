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

func _ready():
	show_press_start()

func show_press_start():
	press_start.visible = true
	mode_select.visible = false

func show_mode_select():
	press_start.visible = false
	mode_select.visible = true

func _input(event):
	var clicked = event is InputEventMouseButton and event.pressed
	if event.is_action_pressed("ui_accept") or clicked:
		if press_start.visible:
			show_mode_select()
