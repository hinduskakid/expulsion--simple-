class_name PersonificationEffect
extends Effect

func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is Enemy:
			if target.stats.is_downed:
				Events.personification_redemption_attempted.emit(target)
			else:
				print("Personification has no effect - enemy is not downed!")
