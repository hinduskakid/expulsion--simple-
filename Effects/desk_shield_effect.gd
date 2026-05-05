class_name DeskShieldEffect
extends Effect

var amount := 0

func execute(targets: Array[Node]) -> void:
	print("DeskShieldEffect executing on ", targets.size(), " targets")
	for target in targets:
		if not target:
			continue
		if target is Enemy:
			target.stats.set_block(target.stats.block + amount)
		elif target.get("stats") != null:  # works for both Player1 and Michla
			target.stats.set_block(target.stats.block + amount)
