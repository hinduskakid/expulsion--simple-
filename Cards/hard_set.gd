extends Card

func apply_effects(targets: Array[Node]) -> void:
	var effect := HardSetEffect.new()
	effect.amount = 2
	effect.execute(targets)
