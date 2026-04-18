@tool
class_name Dialogue
extends Resource

@export var sentences: Array[Sentence] = [Sentence.new()]:
	set(value):
		sentences = value
		if not sentences.is_empty() and sentences.back() == null:
			sentences.pop_back()
			sentences.push_back(Sentence.new())
