class_name PersonificationEffect
extends Effect

func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is Enemy:
			if target.stats.is_downed:
				var roll := randf()
				if roll < 0.666:
					print("Personification redemption successful!")
					target.queue_free()
					Events.player_gained_soul.emit()
				else:
					print("Personification redemption failed!")
			else:
				print("Personification has no effect - enemy is not downed!")
