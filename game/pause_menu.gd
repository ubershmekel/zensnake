extends Control

@onready var music_button = $CenterContainer/VBoxContainer/MusicButton
@onready var sfx_button = $CenterContainer/VBoxContainer/SFXButton

func _ready() -> void:
	visible = false # start hidden
	# If this is shown while paused, set:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_button.set_pressed_no_signal(AudioManager.is_music_enabled())
	sfx_button.set_pressed_no_signal(AudioManager.is_sfx_enabled())

func hide_menu() -> void:
	get_tree().paused = false
	visible = false

func _on_sfx_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.set_sfx_is_playing(true)
		AudioManager.play_eat()
	else:
		AudioManager.set_sfx_is_playing(false)


func _on_music_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.set_music_is_playing(true)
	else:
		AudioManager.set_music_is_playing(false)


func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/main_menu.tscn")


func _on_resume_button_pressed() -> void:
	hide_menu()
