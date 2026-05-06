class_name CharacterStats
extends Stats

@export var starting_deck: CardPile
@export var cards_per_turn: int

var deck: CardPile
var discard: CardPile
var draw_pile: CardPile



func create_instance() -> Resource:
	print("create_instance called")
	print("starting_deck: ", starting_deck)
	print("starting_deck cards: ", starting_deck.cards.size() if starting_deck else "NULL")
	var instance: CharacterStats = self.duplicate(true)
	instance.health = max_health
	instance.block = 0
	instance.deck = instance.starting_deck.duplicate(true)
	print("instance deck size: ", instance.deck.cards.size())
	instance.draw_pile = CardPile.new()
	instance.discard = CardPile.new()
	return instance
