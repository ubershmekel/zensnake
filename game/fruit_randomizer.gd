extends LevelBase

func _ready() -> void:
	for child in get_children():
		if child is FruitClass:
			child.random_position()
			child.random_type()
			child.eaten.connect(_on_fruit_eaten)
			child.eaten_animation_done.connect(_on_fruit_eaten_animation_done)

func _on_fruit_eaten(eater: Node, fruit_data: FruitData) -> void:
	# predetermined behavior: maybe hide that fruit permanently,
	# or spawn next in sequence, etc.
	fruit_eaten.emit(eater, fruit_data)

func _on_fruit_eaten_animation_done(fruit: FruitClass) -> void:
	fruit.random_position()
	fruit.random_type()
