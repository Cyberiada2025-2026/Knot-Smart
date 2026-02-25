# Resource used to configure and store visual settings for the world generator.
## This allows for easy swapping of display profiles (e.g., Low vs. High settings).
class_name WorldDisplayParams
extends Resource

## The radius of chunks to be rendered around the player. 
## Higher values increase visual range but impact GPU/CPU performance.
@export var render_distance: int = 4

## The material applied to the generated mesh surface.
## Expects a type of Material (e.g., StandardMaterial3D or ShaderMaterial).
@export var terrain_material: Material
