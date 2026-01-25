extends Control

@onready var music_volume_slider: HSlider = $CenterContainer/VBoxContainer/MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = $CenterContainer/VBoxContainer/SfxVolumeSlider

func _ready() -> void:
	visible = false # start hidden
	# If this is shown while paused, set:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_volume_slider.value = AudioManager.get_music_volume() * music_volume_slider.max_value
	sfx_volume_slider.value = AudioManager.get_sfx_volume() * sfx_volume_slider.max_value

func hide_menu() -> void:
	get_tree().paused = false
	visible = false


func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/screens/main_menu.tscn")


func _on_resume_button_pressed() -> void:
	hide_menu()

func _on_music_volume_slider_value_changed(value: float) -> void:
	var max_value := music_volume_slider.max_value
	if max_value == 0:
		return
	AudioManager.set_music_volume(value / max_value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	var max_value := sfx_volume_slider.max_value
	if max_value == 0:
		return
	AudioManager.set_sfx_volume(value / max_value)
