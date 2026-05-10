extends Card

func apply_effects(targets: Array[Node]) -> void:
	var effect := PoeticJusticeEffect.new()
	effect.execute(targets)
