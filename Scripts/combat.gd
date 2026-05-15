extends Node2D

#Variables
@onready var party: Array = [$Player1, $Michla, $Nattuo]
@onready var enemy: Enemy = $Enemy
@onready var enemies: Array = [$Enemy, $Enemy2]
@onready var hand: Hand = $BattleUI/Hand

@onready var round_label: Label = $BattleUI/CombatInfo/RoundLabel
@onready var souls_label: Label = $BattleUI/CombatInfo/SoulsLabel
var current_round: int = 0
var player_souls: int = 0
var _selected_member = null
var _race_card_played := false
var _race_member_selected := false
var _enemy_executed_this_round := false
var _enemy_redeemed_this_round := false
var members_played: Array = []
var enemy_turns_to_skip: int = 0
@onready var game_over_layer: CanvasLayer = $BattleUI/GameOverLayer
@onready var game_over_label: Label = $BattleUI/GameOverLayer/ColorRect/GameOverLabel

#SFX
@onready var sfx_player: AudioStreamPlayer2D = $SFXPlayer
const BLOCK_SOUND = preload("res://Assets/audio/audio_block.ogg")
const ATTACK_SOUND = preload("res://Assets/audio/posessedattack.ogg")
const STICK_SOUND = preload("res://Assets/audio/stick_attack_sound.ogg")
const CARDS_PER_TURN := 3



#Functions
func _ready() -> void:
	Events.attack_played.connect(func(): play_sfx(STICK_SOUND))
	Events.party_member_died.connect(func(member):
		if _selected_member == member:
			_selected_member = null)
	Events.party_member_selected.connect(_on_party_member_selected)
	Events.enemy_executed.connect(func(): _enemy_executed_this_round = true)
	Events.enemy_redeemed.connect(func(): _enemy_redeemed_this_round = true)
	Events.delegate_used.connect(_on_delegate_used)
	Events.player_gained_soul.connect(func():
		player_souls += 1
		update_souls_display())
	
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
	
	update_souls_display()
	hand.clear_hand()
	await game_loop()

func _on_party_member_selected(member) -> void:
	print("Party member selected in combat: ", member.name)
	_selected_member = member

func game_loop() -> void:
	while true:
		print("--- New round ", current_round + 1, " ---")
		print("Party alive: ", party.filter(func(m): return is_instance_valid(m)).size())
		current_round += 1
		round_label.text = "Round: " + str(current_round)
		members_played.clear()
		var enemy_index := 0
		while members_played.size() < party.filter(func(m): return is_instance_valid(m) and m.stats.health > 0).size():
			var member = await _wait_for_member_selection(members_played)
			if not is_instance_valid(member):
				continue
			member.stats.set_block(0)
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
			var actual_player = _selected_member
			actual_player.has_played = true
			actual_player.modulate = Color(0.5, 0.5, 0.5)
			members_played.append(actual_player)
			# only one enemy acts per player turn
			var living: Array = get_living_enemies()
			if not living.is_empty():
				if enemy_turns_to_skip > 0:
					print("Enemy turn skipped! ", enemy_turns_to_skip - 1, " remaining")
					enemy_turns_to_skip -= 1
				else:
					var acting_enemy: Enemy = living[enemy_index % living.size()]
					if not acting_enemy.stats.is_downed:
						await enemy_turn_single(acting_enemy)
					enemy_index += 1
			await get_tree().process_frame
			if check_party_dead():
				end_game("You got everyone killed.")
				return
		for member in party:
			if not is_instance_valid(member):
				continue
			member.modulate = Color.WHITE
			member.has_played = false
		round_end()
func _wait_for_member_selection(already_played: Array) -> Node:
	print("Waiting for selection. already_played count: ", already_played.size())
	while true:
		await Events.party_member_selected
		print("Selection signal received. _selected_member: ", _selected_member)
		if _selected_member and is_instance_valid(_selected_member) and not already_played.has(_selected_member):
			return _selected_member
		if _selected_member and not is_instance_valid(_selected_member):
			print("Selected member is dead, clearing")
			_selected_member = null
		elif _selected_member:
			print(_selected_member.name + " already played this round!")
	return party.filter(func(m): return is_instance_valid(m))[0]  # unreachable fallback
	
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
		if is_instance_valid(member) and member.stats.health > 0:
			return false
	return true

func enemy_turn_single(e: Enemy) -> void:
	print("Enemy turn: ", e.name)
	await get_tree().create_timer(0.5).timeout
	var action := randi() % 4
	if action == 0:
		print(e.name + " blocks for 5!")
		play_sfx(BLOCK_SOUND)
		e.stats.set_block(e.stats.block + 5)
	elif action == 1:
		print(e.name + " blocks for 15!")
		play_sfx(BLOCK_SOUND)
		e.stats.set_block(e.stats.block + 15)
	elif action == 2:
		print(e.name + " attacks for 5!")
		var living_party := party.filter(func(m): return is_instance_valid(m))
		if living_party.is_empty():
			return
		var target = living_party[randi() % living_party.size()]
		await enemy_lunge_specific(e, target)
		play_sfx(ATTACK_SOUND)
		target.take_damage(5)
	else:
		print(e.name + " attacks for 25!")
		var living_party := party.filter(func(m): return is_instance_valid(m))
		if living_party.is_empty():
			return
		var target = living_party[randi() % living_party.size()]
		await enemy_lunge_specific(e, target)
		play_sfx(ATTACK_SOUND)
		target.take_damage(25)
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
	_enemy_executed_this_round = false
	_enemy_redeemed_this_round = false
	hand.clear_hand()
	for e in get_living_enemies():
		e.stats.set_block(0)
	for e in enemies:
		if is_instance_valid(e) and e.stats.is_downed:
			e.stats.downed_rounds_remaining -= 1
			if e.stats.downed_rounds_remaining <= 0:
				e.revive()

func end_game(message: String) -> void:
	print(message)
	game_over_label.text = message
	game_over_layer.visible = true

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

func play_sfx(sound: AudioStream) -> void:
	sfx_player.stream = sound
	sfx_player.play()

func update_souls_display() -> void:
	souls_label.text = "Souls: " + str(player_souls)

func _on_delegate_used(member: Node) -> void:
	members_played.erase(member)
