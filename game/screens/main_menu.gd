extends Control

func _on_button_2p_pressed() -> void:
	play(2)

func _on_button_1p_pressed() -> void:
	play(1)

func play(playerCount: int) -> void:
	var next_scene = load("res://game/screens/game.tscn").instantiate()
	next_scene.player_count = playerCount
	get_tree().root.add_child(next_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = next_scene
