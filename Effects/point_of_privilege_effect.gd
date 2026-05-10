class_name PointOfPrivilegeEffect
extends Effect

func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is Enemy:
			if target.stats.health <= 10:
				print("Point of Privilege: auto-executing low HP enemy!")
				target.queue_free()
				Events.enemy_executed.emit()
			else:
				print("Point of Privilege: enemy has more than 10 HP, no effect")
