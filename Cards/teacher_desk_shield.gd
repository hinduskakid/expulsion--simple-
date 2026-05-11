extends Card

func apply_effects(targets: Array[Node]) -> void:
	var effect := TeacherDeskShieldEffect.new()
	effect.execute(targets)
