extends Node

#region Tile Map Layer Generation

# Tile set pngs used for layer generation
const DIG_TILES: String = "uid://co8rcfht5qxyy"

# Variables for the tile map layer generation
var dig_width: int = 4
var dig_height: int = 4
var tile_size: Vector2i = Vector2i(16,16)
var dig_tile_texture: Texture2D
var dig_tile_set: TileSet
var dig_tile_source: TileSetAtlasSource
var dig_atlas_coords: Array

@onready var dig_area: TileMapLayer = $DigArea
#endregion


func _ready() -> void:
	_create_layer_tile_map.call_deferred()


func _create_layer_tile_map() -> void:
	dig_tile_source = TileSetAtlasSource.new()
	dig_tile_texture = load(DIG_TILES)
	dig_tile_source.texture = dig_tile_texture
	dig_tile_source.texture_region_size = tile_size
	
	dig_tile_set = TileSet.new()
	dig_tile_set.tile_size = tile_size
	dig_tile_set.add_physics_layer(0)
	dig_tile_set.set_physics_layer_collision_layer(0,2)
	dig_tile_set.set_physics_layer_collision_mask(0,2)
	dig_tile_set.add_source(dig_tile_source,0)
	dig_area.tile_set = dig_tile_set
	
	var tile_collision_polygon: PackedVector2Array = PackedVector2Array([
				Vector2(-tile_size.x/2.0, -tile_size.y/2.0),
				Vector2(tile_size.x/2.0, -tile_size.y/2.0),
				Vector2(tile_size.x/2.0, tile_size.y/2.0),
				Vector2(-tile_size.x/2.0, tile_size.y/2.0),
				])
	
	for x_pos in int(dig_tile_texture.get_size().x / tile_size.x):
		for y_pos in int(dig_tile_texture.get_size().y / tile_size.y):
			var atlas_coords: Vector2i = Vector2i(x_pos,y_pos)
			dig_tile_source.create_tile(Vector2i(x_pos,y_pos))
			dig_atlas_coords.append(atlas_coords)
			
			if dig_tile_source.get_tile_data(atlas_coords, 0):
				dig_tile_source.get_tile_data(atlas_coords, 0).add_collision_polygon(0)
				dig_tile_source.get_tile_data(atlas_coords, 0).set_collision_polygon_points(
					0,
					0,
					tile_collision_polygon,
				)
	
	for x_pos in dig_width:
		@warning_ignore("integer_division")
		for y_pos in dig_height:
			dig_area.set_cell(Vector2i(x_pos,y_pos), 0, dig_atlas_coords.pick_random())
