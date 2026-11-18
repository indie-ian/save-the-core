extends Node
class_name ObjectFactory

const LARGE_DAMAGE_DEPOSIT_SCENE: String = "uid://dxcygfhn4d26s"
const MEDIUM_DAMAGE_DEPOSIT_SCENE: String = "uid://d4efd2wuk8jyh"
const SMALL_DAMAGE_DEPOSIT_SCENE: String = "uid://eka4lmkl2k3a"


static func create_static_damage_deposit(deposit_size: Library.DepositSize) -> DamageDeposit:
	match deposit_size:
		Library.DepositSize.LARGE:
			var new_deposit_scene: PackedScene = load(LARGE_DAMAGE_DEPOSIT_SCENE)
			var new_deposit: DamageDeposit = new_deposit_scene.instantiate()
			return new_deposit
		Library.DepositSize.MEDIUM:
			var new_deposit_scene: PackedScene = load(MEDIUM_DAMAGE_DEPOSIT_SCENE)
			var new_deposit: DamageDeposit = new_deposit_scene.instantiate()
			return new_deposit
		Library.DepositSize.SMALL:
			var new_deposit_scene: PackedScene = load(SMALL_DAMAGE_DEPOSIT_SCENE)
			var new_deposit: DamageDeposit = new_deposit_scene.instantiate()
			return new_deposit
		_:
			printerr("Object Factory : create_static_damage_deposit : Deposit size not found.")
			return null
	

static func create_floating_damage_deposit(deposit_size: Library.DepositSize) -> DamageDeposit:
	match deposit_size:
		Library.DepositSize.LARGE:
			var new_deposit_scene: PackedScene = load(LARGE_DAMAGE_DEPOSIT_SCENE)
			var new_deposit: DamageDeposit = new_deposit_scene.instantiate()
			return new_deposit
		Library.DepositSize.MEDIUM:
			var new_deposit_scene: PackedScene = load(MEDIUM_DAMAGE_DEPOSIT_SCENE)
			var new_deposit: DamageDeposit = new_deposit_scene.instantiate()
			return new_deposit
		Library.DepositSize.SMALL:
			var new_deposit_scene: PackedScene = load(SMALL_DAMAGE_DEPOSIT_SCENE)
			var new_deposit: DamageDeposit = new_deposit_scene.instantiate()
			return new_deposit
		_:
			printerr("Object Factory : create_floating_damage_deposit : Deposit size not found.")
			return null

static func create_static_health_deposit() -> void:
	pass

static func create_floating_health_deposit() -> void:
	pass

static func create_static_slow_deposit() -> void:
	pass

static func create_floating_slow_deposit() -> void:
	pass
