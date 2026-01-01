extends LevelBase

func _ready() -> void:
	var fruits = get_tree().get_nodes_in_group("fruits")
	for fruit in fruits:
		fruit.random_position()
		fruit.random_type()
		fruit.eaten.connect(_on_fruit_eaten)
		fruit.eaten_animation_done.connect(_on_fruit_eaten_animation_done)

func _on_fruit_eaten(eater: Node, fruit_data: FruitData) -> void:
	# predetermined behavior: maybe hide that fruit permanently,
	# or spawn next in sequence, etc.
	fruit_eaten.emit(eater, fruit_data)

func _on_fruit_eaten_animation_done(fruit: FruitClass) -> void:
	fruit.random_position()
	fruit.random_type()
