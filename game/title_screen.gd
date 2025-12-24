extends Control

func _on_hold_button_tutorial_intro_complete() -> void:
	var next_scene = load("res://game/main_menu.tscn").instantiate()
	get_tree().root.add_child(next_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = next_scene
