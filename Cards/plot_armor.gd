extends Card

func apply_effects(targets: Array[Node]) -> void:
	var effect := PlotArmorEffect.new()
	effect.execute(targets)
