extends Node2D

#Variables
@onready var party: Array = [$Player1, $Michla, $Nattuo]
@onready var enemy: Enemy = $Enemy
@onready var enemies: Array = [$Enemy, $Enemy2]
@onready var hand: Hand = $BattleUI/Hand
var player_souls: int = 0
var _selected_member = null
var _race_card_played := false
var _race_member_selected := false

const CARDS_PER_TURN := 3

#Functions
func _ready() -> void:
	Events.party_member_selected.connect(_on_party_member_selected)
	for member in party:
		print(member.name, " stats: ", member.stats)
		if member.stats == null:
			print("ERROR: ", member.name, " has no stats assigned!")
			return
		if member.stats.deck == null:
			print("ERROR: ", member.name, " has no starting deck assigned!")
			return
		print(member.name, " deck size: ", member.stats.deck.cards.size())
		print(member.name, " draw_pile: ", member.stats.draw_pile)
		member.stats.draw_pile.cards = member.stats.deck.cards.duplicate()
		print(member.name, " draw_pile size after copy: ", member.stats.draw_pile.cards.size())
		member.stats.draw_pile.shuffle()
	hand.clear_hand()
	await game_loop()

func _on_party_member_selected(member) -> void:
	print("Party member selected in combat: ", member.name)
	_selected_member = member

func game_loop() -> void:
	var members_played := []
	while true:
		members_played.clear()

		while members_played.size() < party.size():
			var member = await _wait_for_member_selection(members_played)

			hand.clear_hand()
			hand.preview_cards(CARDS_PER_TURN, member.stats)

			var action = await _wait_for_card_or_reselect(member, members_played)

			if action == "reselected":
				continue

			hand.clear_hand()
			await get_tree().process_frame

			if all_enemies_dead():
				end_game("You win!")
				return

			member.has_played = true
			member.modulate = Color(0.5, 0.5, 0.5)
			members_played.append(member)

			if get_living_enemies().any(func(e): return not e.stats.is_downed):
				await enemy_turn()
			else:
				round_end()
				if all_enemies_dead():
					end_game("You win!")
					return
				continue

			if check_party_dead():
				end_game("You lose!")
				return

		for member in party:
			member.modulate = Color.WHITE
			member.has_played = false

		round_end()

func _wait_for_member_selection(already_played: Array) -> Node:
	print("Waiting... already_played: ", already_played)
	while true:
		await Events.party_member_selected
		print("Signal received in _wait_for_member_selection: ", _selected_member.name if _selected_member else "null")
		if _selected_member and not already_played.has(_selected_member):
			return _selected_member
		print(_selected_member.name + " already played this round!")
	return party[0]

func _wait_for_card_or_reselect(current_member, already_played: Array) -> String:
	while true:
		var result = await _race_signals()
		if result == "card_played":
			return "card_played"
		if _selected_member != current_member and not already_played.has(_selected_member):
			hand.clear_hand()
			hand.preview_cards(CARDS_PER_TURN, _selected_member.stats)
			current_member = _selected_member
	return "card_played"

func _race_signals() -> String:
	_race_card_played = false
	_race_member_selected = false

	Events.card_played.connect(_on_race_card_played, CONNECT_ONE_SHOT)
	Events.party_member_selected.connect(_on_race_member_selected, CONNECT_ONE_SHOT)

	while not _race_card_played and not _race_member_selected:
		await get_tree().process_frame

	if Events.card_played.is_connected(_on_race_card_played):
		Events.card_played.disconnect(_on_race_card_played)
	if Events.party_member_selected.is_connected(_on_race_member_selected):
		Events.party_member_selected.disconnect(_on_race_member_selected)

	if _race_card_played:
		return "card_played"
	return "selected"

func _on_race_card_played(_c) -> void:
	_race_card_played = true

func _on_race_member_selected(_m) -> void:
	_race_member_selected = true

func check_party_dead() -> bool:
	for member in party:
		if member.stats.health > 0:
			return false
	return true

func enemy_turn() -> void:
	print("Enemy turn")
	await get_tree().create_timer(0.5).timeout
	for e in get_living_enemies():
		if e.stats.is_downed:
			continue
		var action := randi() % 2
		if action == 0:
			print(e.name + " attacks!")
			var target = party[randi() % party.size()]
			await enemy_lunge_specific(e, target)
			target.stats.take_damage(10)
		else:
			print(e.name + " blocks!")
			e.stats.set_block(5)
		await get_tree().create_timer(0.3).timeout

func enemy_lunge_specific(e: Enemy, target: Node2D) -> void:
	var original_pos := e.global_position
	var target_pos := Vector2(target.global_position.x + 100, e.global_position.y)

	var lunge_tween := create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	lunge_tween.tween_property(e, "global_position", target_pos, 0.2)
	await lunge_tween.finished

	await get_tree().create_timer(0.1).timeout

	var return_tween := create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	return_tween.tween_property(e, "global_position", original_pos, 0.3)
	await return_tween.finished

func round_end() -> void:
	print("Round end")
	hand.clear_hand()
	for e in enemies:
		if is_instance_valid(e) and e.stats.is_downed:
			e.stats.downed_rounds_remaining -= 1
			print(e.name + " downed for %d more rounds" % e.stats.downed_rounds_remaining)
			if e.stats.downed_rounds_remaining <= 0:
				e.revive()

func end_game(message: String) -> void:
	print(message)

func all_enemies_dead() -> bool:
	for e in enemies:
		if is_instance_valid(e):
			return false
	return true

func get_living_enemies() -> Array:
	var living := []
	for e in enemies:
		if is_instance_valid(e):
			living.append(e)
	return living
