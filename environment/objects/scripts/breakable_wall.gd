extends StaticBody2D

@onready var wall_collision: CollisionPolygon2D = $WallCollision
@onready var wall_sprite: Sprite2D = $WallSprite
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

func destroy() -> void:
	wall_collision.disabled = true
	cpu_particles_2d.emitting = true
	var destroy_tween: Tween = create_tween()
	destroy_tween.set_trans(Tween.TRANS_BOUNCE)
	destroy_tween.set_ease(Tween.EASE_OUT)
	destroy_tween.tween_property(wall_sprite, "modulate:a", 0.0, 1.0)
	await destroy_tween.finished
	queue_free()
