class_name RandomNumberGeneratorUpgraded
extends RandomNumberGenerator

func pick_random(array: Array):
	var element
	if array.is_empty():
		element = null
	else:
		element = array[self.randi_range(0, array.size()-1)]
	return element

## https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
func shuffle(array: Array):
	for i in range(array.size()):
		var random: int = self.randi_range(0, array.size()-1)
		if random != array.size()-1:
			array.insert(random, array.pop_back())
			array.push_back(array.pop_at(random+1))
