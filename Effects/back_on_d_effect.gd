class_name BackOnDEffect
extends Effect

func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target.get("stats") != null and target.stats.get("attack_modifier") != null:
			var block_amount: int = target.stats.attack_modifier * 3
			target.stats.set_block(target.stats.block + block_amount)
			print("Back on D: gained ", block_amount, " block")
