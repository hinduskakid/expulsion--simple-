class_name Hand
extends HBoxContainer

@export var card_ui_scene: PackedScene

func _ready() -> void:
	for child in get_children():
		var card_ui := child as CardUI
		card_ui.parent = self
		card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)

func add_card(card: Card, char_stats: CharacterStats) -> void:
	var card_ui: CardUI = card_ui_scene.instantiate()
	add_child(card_ui)
	card_ui.parent = self
	card_ui.char_stats = char_stats
	card_ui.card = card
	card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)

func clear_hand() -> void:
	for child in get_children():
		child.queue_free()

func preview_cards(amount: int, stats: CharacterStats) -> void:
	var preview_count = min(amount, stats.draw_pile.cards.size())
	for i in preview_count:
		var card = stats.draw_pile.cards[i]
		var card_ui: CardUI = card_ui_scene.instantiate()
		add_child(card_ui)
		card_ui.parent = self
		card_ui.char_stats = stats
		card_ui.card = card
		card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)

func _on_card_ui_reparent_requested(child: CardUI) -> void:
	child.reparent(self)
