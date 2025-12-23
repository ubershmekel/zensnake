extends Node2D
class_name LevelBase

@warning_ignore("unused_signal")
signal fruit_eaten(eater: Node, fruit: FruitData)
@warning_ignore("unused_signal")
signal level_done()

# Level-specific configuration
@export var growth_per_fruit: int = 1
