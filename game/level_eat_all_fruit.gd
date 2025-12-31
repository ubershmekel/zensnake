extends LevelBase

var _remaining_fruits: int = 0

func _ready() -> void:
	_count_fruits()
	var fruits = get_tree().get_nodes_in_group("fruits")
	for fruit in fruits:
		fruit.eaten.connect(_on_fruit_eaten)
		fruit.eaten_animation_done.connect(_on_fruit_eaten_animation_done)

func _count_fruits() -> void:
	_remaining_fruits = get_tree().get_nodes_in_group("fruits").size()

func _on_fruit_eaten(eater: Node, fruit_data: FruitData) -> void:
	# Emit signal so game can react to fruit being eaten
	fruit_eaten.emit(eater, fruit_data)
	# In the pattern fruit spawner we have fruits that get freed without any
	# signals sent, so count the remaining fruit every time they eat
	_count_fruits()

func _on_fruit_eaten_animation_done(fruit: FruitClass) -> void:
	# Instead of respawning the fruit like fruit_randomizer does,
	# we delete it to complete the "eat all fruit" level objective
	fruit.queue_free()
	_remaining_fruits -= 1
	
	# Check if all fruits have been eaten
	if _remaining_fruits <= 0:
		level_done.emit()
