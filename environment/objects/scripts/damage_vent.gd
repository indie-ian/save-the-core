extends Node2D

@onready var spawn_marker: Marker2D = $SpawnMarker
@onready var despawn: Area2D = $Despawn
@onready var spawn_timer: Timer = $SpawnTimer
@onready var damage_deposits: Node2D = $DamageDeposits


func _ready() -> void:
	despawn.body_entered.connect(_despawn_deposit)
	spawn_timer.timeout.connect(_spawn_damage_deposit)


func _spawn_damage_deposit() -> void:
	var new_damage_deposit: DamageDeposit = ObjectFactory.create_floating_damage_deposit(Library.DepositSize.values().pick_random())
	damage_deposits.add_child(new_damage_deposit)
	new_damage_deposit.global_position = spawn_marker.global_position
	new_damage_deposit.rotation_degrees = randf_range(0,360)
	new_damage_deposit.floating = true

func _despawn_deposit(body: Node2D) -> void:
	if body is DamageDeposit:
		body.queue_free.call_deferred()
		spawn_timer.start()
