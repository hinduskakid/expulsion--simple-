class_name Stats
extends Resource
signal stats_changed

var health: int: set = set_health 
var block: int : set = set_block
@export var art: Texture
@export var max_health := 999


func set_health(value : int) -> void:
	health = clampi(value, 0, max_health)
	stats_changed.emit()
	
	
func take_damage(damage : int) -> void:
	if damage <= 0:
		return
	var initial_damage = damage
	damage = clampi(damage - block, 0, damage)
	block = clampi(block - initial_damage, 0, block)
	health -= damage

func set_block(value : int) -> void:
	block = clampi(value, 0, 999)
	stats_changed.emit()

func create_instance() -> Resource:
	var instance: Stats = self.duplicate()
	instance.health = instance.max_health
	instance.block = 0
	return instance

func heal(amount : int) -> void:
	health += amount
