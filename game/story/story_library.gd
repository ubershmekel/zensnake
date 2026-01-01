extends Resource
class_name StoryLibrary

@export var sequences: Array[StoryText]

func pick_random(rng: RandomNumberGenerator) -> StoryText:
	if sequences.is_empty():
		return null
	return sequences[rng.randi_range(0, sequences.size() - 1)]
