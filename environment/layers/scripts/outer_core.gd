extends Node2D

@export var player: CharacterBody2D

var player_is_safe: bool = true
var check_if_safe: bool = false

@onready var safe_start: Area2D = $SafeStart
@onready var hurt_area: Area2D = $HurtArea
@onready var win_area: Area2D = $WinArea
@onready var heat_timer: Timer = $HeatTimer

func _ready() -> void:
	win_area.body_entered.connect(_end_game)
	hurt_area.body_entered.connect(_start_checks)
	heat_timer.timeout.connect(_heat_player)

func _physics_process(_delta: float) -> void:
	if check_if_safe:
		for platform in get_tree().get_nodes_in_group("safe_platform"):
			if platform.get_overlapping_bodies().has(player):
				player_is_safe = true
				return
			else:
				player_is_safe = false
	if !player_is_safe and player.velocity == Vector2.ZERO and heat_timer.is_stopped():
		_heat_player()
		heat_timer.start()


func _heat_player() -> void:
	player._apply_hard_hit()


func _start_checks(body: Node2D) -> void:
	if body is CharacterBody2D:
		check_if_safe = true


# Player finishes the game.
func _end_game(_body: Node2D) -> void:
	Global.manager.game_state.end_time()
	Global.manager.update_node2d_tree(Library.FINAL_SCENE)
	Global.manager.current_ui.queue_free()
