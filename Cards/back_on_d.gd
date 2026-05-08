extends Card

func apply_effects(targets: Array[Node]) -> void:
	var effect := BackOnDEffect.new()
	effect.execute(targets)
