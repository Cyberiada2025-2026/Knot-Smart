class_name AlienMoods

enum Moods { angry, zesty, fast, scared, suprised, neutral }


static func get_mood_name(mood: Moods) -> String:
	return Moods.keys()[mood]
