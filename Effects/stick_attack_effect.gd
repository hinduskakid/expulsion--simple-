class_name StickAttackEffect
extends Effect

var amount := 0

func execute(targets: Array[Node]) -> void:
	print("StickAttackEffect executing on ", targets.size(), " targets")
	for target in targets:
		print("Target: ", target, " is Enemy: ", target is Enemy, " is Player: ", target is Player)
		if not target:
			continue
		if target is Enemy:
			target.take_damage(amount)
			Events.attack_played.emit()
		elif target is Player:
			target.take_damage(amount)
