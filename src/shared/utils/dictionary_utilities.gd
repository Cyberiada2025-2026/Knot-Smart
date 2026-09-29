class_name DictionaryUtilities


## Deep-merge the [param source] dictionary into [param destination]. [br]
## Similar to [method Dictionary.merge] with [code]overwrite=true[/code],
## but also recursively deep-merges nested dictionaries.
static func deep_merge(source: Dictionary, destination: Dictionary) -> void:
	for key in source:
		if source[key] is Dictionary and destination.has(key):
			deep_merge(source[key], destination[key])
		else:
			destination[key] = source[key]
