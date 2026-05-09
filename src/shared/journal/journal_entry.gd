class_name JournalEntry
extends Resource

@export_category("Journal entry information")
## Name of an object
@export var object_name: String
## Description of the object
@export_multiline() var description: String
## What page the object should be at
@export var page: Journal.PageType = Journal.PageType.ITEMS

@export_category("Model information")
## Model of visible in an entry. If null no preview will be visible
@export_file var model_scene: String
## Scale of the model
@export var model_scale: float = 0.5
## Angle in radians that object should rotate by per second.
@export var rotation_angle: float = 0.1
