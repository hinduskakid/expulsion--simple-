extends Card

func apply_effects(targets: Array[Node]) -> void:
	var effect := PointOfPrivilegeEffect.new()
	effect.execute(targets)
