extends Control

func _ready() -> void:
	visible = false  # start hidden
	# If this is shown while paused, set:
	process_mode = Node.PROCESS_MODE_ALWAYS

func hide_menu() -> void:
	get_tree().paused = false
	visible = false

func _on_sfx_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.sfx_yes()
		AudioManager.play_eat()
	else:
		AudioManager.sfx_no()


func _on_music_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.music_yes()
	else:
		AudioManager.music_no()


func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/main_menu.tscn")


func _on_resume_button_pressed() -> void:
	hide_menu()
