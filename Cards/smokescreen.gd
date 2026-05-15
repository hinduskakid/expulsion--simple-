extends Card

func apply_effects(targets: Array[Node]) -> void:
	var effect := SmokescreenEffect.new()
	effect.execute(targets)
