extends Node2D
class_name EarthLayer

@export_enum( 
	"CRUST", 
	"UPPER_MANTLE", 
	"LOWER_MANTLE", 
	"OUTER_CORE", 
	"INNER_CORE",
	) var layer_type: String
@export_range(64,6400,64) var layer_depth: int = 64 # Divisible by 64
@export var damage_deposit_count: int = 0
@export var health_deposit_count: int = 0
@export var slow_deposit_count: int = 0

const CRUST_BACKGROUND_TILES: String = "uid://bb6f5hfhnpoy5"
const CRUST_FOREGROUND_TILES: String = "uid://co8rcfht5qxyy"

var layer_width: int
var tile_size: Vector2i = Vector2i(8,8)

var background_tile_texture: Texture2D
var foreground_tile_texture: Texture2D
var background_tile_set: TileSet
var foreground_tile_set: TileSet
var background_tile_source: TileSetAtlasSource
var foreground_tile_source: TileSetAtlasSource
var background_atlas_coords: Array
var foreground_atlas_coords: Array

@onready var background: TileMapLayer = $Background
@onready var foreground: TileMapLayer = $Foreground


func _ready() -> void:
	_create_layer_tile_map.call_deferred()

func _create_layer_tile_map() -> void:
	background_tile_source = TileSetAtlasSource.new()
	foreground_tile_source = TileSetAtlasSource.new()
	
	match layer_type:
		"CRUST":
			background_tile_texture = load(CRUST_BACKGROUND_TILES)
			foreground_tile_texture = load(CRUST_FOREGROUND_TILES)
			background_tile_source.texture = background_tile_texture
			foreground_tile_source.texture = foreground_tile_texture
		"UPPER_MANTLE":
			background_tile_texture = load(CRUST_BACKGROUND_TILES)
			foreground_tile_texture = load(CRUST_FOREGROUND_TILES)
			background_tile_source.texture = background_tile_texture
			foreground_tile_source.texture = foreground_tile_texture
		"LOWER_MANTLE":
			background_tile_texture = load(CRUST_BACKGROUND_TILES)
			foreground_tile_texture = load(CRUST_FOREGROUND_TILES)
			background_tile_source.texture = background_tile_texture
			foreground_tile_source.texture = foreground_tile_texture
		"OUTER_CORE":
			background_tile_texture = load(CRUST_BACKGROUND_TILES)
			foreground_tile_texture = load(CRUST_FOREGROUND_TILES)
			background_tile_source.texture = background_tile_texture
			foreground_tile_source.texture = foreground_tile_texture
		"INNER_CORE":
			background_tile_texture = load(CRUST_BACKGROUND_TILES)
			foreground_tile_texture = load(CRUST_FOREGROUND_TILES)
			background_tile_source.texture = background_tile_texture
			foreground_tile_source.texture = foreground_tile_texture
		_:
			printerr("Layer Type: Layer type not found.")
	
	background_tile_source.texture_region_size = tile_size
	foreground_tile_source.texture_region_size = tile_size
	
	background_tile_set = TileSet.new()
	background_tile_set.tile_size = tile_size
	background_tile_set.add_source(background_tile_source,0)
	background.tile_set = background_tile_set
	
	foreground_tile_set = TileSet.new()
	foreground_tile_set.tile_size = tile_size
	foreground_tile_set.add_physics_layer(0)
	foreground_tile_set.set_physics_layer_collision_layer(0,2)
	foreground_tile_set.set_physics_layer_collision_mask(0,2)
	foreground_tile_set.add_source(foreground_tile_source,0)
	foreground.tile_set = foreground_tile_set
	
	
	for x_pos in int(background_tile_texture.get_size().x / tile_size.x):
		for y_pos in int(background_tile_texture.get_size().y / tile_size.y):
			var atlas_coords: Vector2i = Vector2i(x_pos,y_pos)
			background_tile_source.create_tile(atlas_coords)
			background_atlas_coords.append(atlas_coords)
	
	var tile_collision_polygon: PackedVector2Array = PackedVector2Array([
				Vector2(-tile_size.x/2, -tile_size.y/2),
				Vector2(tile_size.x/2, -tile_size.y/2),
				Vector2(tile_size.x/2, tile_size.y/2),
				Vector2(-tile_size.x/2, tile_size.y/2),
				])
	
	for x_pos in int(foreground_tile_texture.get_size().x / tile_size.x):
		for y_pos in int(foreground_tile_texture.get_size().y / tile_size.y):
			var atlas_coords: Vector2i = Vector2i(x_pos,y_pos)
			foreground_tile_source.create_tile(Vector2i(x_pos,y_pos))
			foreground_atlas_coords.append(atlas_coords)
			
			if foreground_tile_source.get_tile_data(atlas_coords, 0):
				foreground_tile_source.get_tile_data(atlas_coords, 0).add_collision_polygon(0)
				foreground_tile_source.get_tile_data(atlas_coords, 0).set_collision_polygon_points(
					0,
					0,
					tile_collision_polygon,
				)
	
	layer_width = int(get_viewport_rect().size.x / tile_size.x)
	
	for x_pos in layer_width:
		@warning_ignore("integer_division")
		for y_pos in int(layer_depth / tile_size.y):
			background.set_cell(Vector2i(x_pos,y_pos), 0, background_atlas_coords.pick_random())
	
	for x_pos in layer_width:
		@warning_ignore("integer_division")
		for y_pos in int(layer_depth / tile_size.y):
			foreground.set_cell(Vector2i(x_pos,y_pos), 0, foreground_atlas_coords.pick_random())
	
	
