extends Area2D

var turbo_drilling: bool = false

@export var drill_area: Vector2 = Vector2(24,24)
@export var rig: CharacterBody2D # Player mining rig

func _ready() -> void:
	body_entered.connect(_drill_strike)

func _physics_process(_delta: float) -> void:
	if rig.velocity == Vector2.ZERO:
		turbo_drilling = false
	
	if has_overlapping_bodies() and (rig.velocity > Vector2.ZERO or rig.velocity < Vector2.ZERO):
		for body in get_overlapping_bodies():
			if body is TileMapLayer:
				_drill_floor(body)

func _drill_floor(body: Node2D) -> void:
	var hit_hard_tile: bool = false
	var hit_slow_tile: bool = false
	var hit_coolant_tile: bool = false
	
	for x_pos in drill_area.x / 2:
		for y_pos in drill_area.y / 2:
			var q1: Vector2 = body.to_local(
				Vector2(global_position.x - x_pos, global_position.y - y_pos))
			var q2: Vector2 = body.to_local(
				Vector2(global_position.x + x_pos, global_position.y + y_pos))
			var q3: Vector2 = body.to_local(
				Vector2(global_position.x - x_pos, global_position.y + y_pos))
			var q4: Vector2 = body.to_local(
				Vector2(global_position.x + x_pos, global_position.y - y_pos))
			
			for point in [q1, q2, q3, q4]:
				var map_pos = body.local_to_map(point)
				var tile_data = body.get_cell_tile_data(map_pos)
				if tile_data and tile_data.get_custom_data("hard") == true and !turbo_drilling:
					hit_hard_tile = true
				elif tile_data and tile_data.get_custom_data("slow") == true:
					hit_slow_tile = true
				elif tile_data and tile_data.get_custom_data("liquid") == true:
					hit_coolant_tile = true
					body.erase_cell(map_pos)
				else:
					body.erase_cell(map_pos)
		
	if hit_hard_tile:
		rig._add_damage(rig.DAMAGE_BREAKABLE)
		rig._add_red_temp(5.0)
	if hit_slow_tile:
		if !turbo_drilling:
			rig._apply_slow_effect()
	if hit_coolant_tile:
		rig._collect_liquid(0.5)

func _drill_strike(body: Node2D) -> void:
	if body is TileMapLayer:
		return
	
	if body.is_in_group("breakable"):
		if turbo_drilling:
			rig._apply_soft_hit()
			body.destroy.call_deferred()
		else:
			rig._apply_soft_hit()
			
	else:
		rig._apply_hard_hit()
