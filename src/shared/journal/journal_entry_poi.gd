class_name JournalEntryPOI
extends Node

@export var journal_entry: JournalEntry


func _ready() -> void:
	var poi: PointOfInterest = get_parent() as PointOfInterest
	if poi == null:
		push_warning("JournalEntryPOI will not work without a PointOfInterest as a parent.")
		return

	poi.triggered.connect(on_object_notice)


func on_object_notice(_entity: Node3D) -> void:
	var journal = get_tree().get_first_node_in_group("Player").get_node("Journal")
	journal.add_object(self)
	self.queue_free()
