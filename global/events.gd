extends Node
# Card-related events
signal card_drag_started(card_ui: CardUI)
signal card_drag_ended(card_ui: CardUI)
signal card_aim_started(card_ui: CardUI)
signal card_aim_ended(card_ui: CardUI)
signal card_played(card: Card)
signal enemy_attacked_while_downed(enemy: Enemy)
signal player_gained_soul
signal personification_redemption_attempted(enemy: Enemy)
signal party_member_selected(member: Node)
