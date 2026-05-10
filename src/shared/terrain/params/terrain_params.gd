@tool
class_name TerrainParams
extends Resource

@export_range(-0.5, 0.5, 0.05) var height_displacement := -0.5

## The noise algorithm used to calculate elevation.
@export var noise: FastNoiseLite

## The material applied to the generated mesh surface.
## Expects a type of Material (e.g., StandardMaterial3D or ShaderMaterial).
@export var terrain_material: Material
