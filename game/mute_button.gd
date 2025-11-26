extends CheckButton

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.play_music()
	else:
		AudioManager.stop_music()
