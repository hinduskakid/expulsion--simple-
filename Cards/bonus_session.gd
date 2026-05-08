extends Card

func apply_effects(targets: Array[Node]) -> void:
	var effect := BonusSessionEffect.new()
	effect.execute(targets)
