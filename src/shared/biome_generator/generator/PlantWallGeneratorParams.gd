@tool
class_name PlantWallGeneratorParams
extends Resource



@export var custom_seed: int = 0

@export_group("location")
@export var size: Vector2 = Vector2(200, 200)
@export var start: Vector2 = Vector2(-100, -100)

@export_group("points")
## number of points in x/z
@export var points_in: Vector2 = Vector2(50, 50)
## number of points from border that will not be affected by randomization
@export var randomization_margin: int = 0
## percentage of half averange distance
@export var randomization_strength: Vector2 = Vector2(0.99, 0.99)

@export_group("triangles selection")
## chance to shuffle possible triangles, during every selection of next biome triangle
@export var chance_to_shuffle: float = 0.01

@export_group("biomes")
## Minimal area of biomes in m^2
@export var biomes_desired_minimum_area: Dictionary[String, int] = {
	"biome1": 10000,
	"biome2": 10000,
	"biome3": 10000
}

@export_group("passages")
@export var passage_prefab: PackedScene = preload(
	"res://shared/biome_generator/wall/biome_passage.tscn"
)
@export var number_of_passages_per_biomes_border: int = 3



func regenerate_seed() -> void:
	custom_seed = randi()
