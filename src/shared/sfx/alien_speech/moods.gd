class_name AlienMoods

enum Moods { ANGRY, ZESTY, FAST, SCARED, SUPRISED, NEUTRAL }


static func get_mood_name(mood: Moods) -> String:
	return Moods.keys()[mood].to_lower()
