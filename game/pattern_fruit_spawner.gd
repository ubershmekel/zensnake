extends Node

func _ready() -> void:
	randomize()
	var children = get_children()
	if children.is_empty():
		return
	var chosen: Node2D = children[randi() % children.size()]
	for child in children:
		if child == chosen:
			child.visible = true
			continue
		child.queue_free()

	# randomize all the fruits to one kind
	var fruits = get_tree().get_nodes_in_group("fruits")
	var fruit_type = fruits[0].random_type(true)
	for fruit in fruits:
		fruit.fruit_data = fruit_type
