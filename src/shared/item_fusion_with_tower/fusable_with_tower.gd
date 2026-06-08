class_name FusableWithTower
extends Node

@export var dialogue: Dialogue

## triggers dialogue connected with item that will be fused [br]
## after paying dialogue deletes parent node!!!
func trigger_dialogue_and_delete_node():
	if dialogue:
		var player_group = get_tree().get_nodes_in_group("Player")
		if player_group.is_empty():
			push_warning("No Player found for playing fusion dialogue. Skipped.")
			return

		var player = player_group[0]
		for sentence in dialogue.sentences:
			var subtitle = sentence.text
			SubtitleManager.display(subtitle)
			var translated = LanguageGenerator.process_dialogue(subtitle)
			await player.get_node("SpeechManager").play_speech(translated)
			SubtitleManager.hide()
	get_parent().queue_free()
