class_name CharacterStats
extends Stats

@export var starting_deck: CardPile
@export var cards_per_turn: int

var deck: CardPile
var discard: CardPile
var draw_pile: CardPile



func create_instance() -> Resource:
	var instance: CharacterStats = self.duplicate()
	instance.health = max_health
	instance.block = 0
	instance.deck = instance.starting_deck.duplicate()
	instance.draw_pile = CardPile.new()
	instance.discard = CardPile.new()
	return instance
