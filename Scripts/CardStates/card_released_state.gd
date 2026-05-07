extends CardState
var played: bool

func enter() -> void:
	played = false
	var is_single_targeted := card_ui.card.is_single_targeted()
	if is_single_targeted and not card_ui.targets.is_empty():
		played = true
		card_ui.play()
	elif not is_single_targeted:
		played = true
		card_ui.play()

func on_input(_event: InputEvent) -> void:
	if played:
		return
	transition_requested.emit(self, CardState.State.BASE)
