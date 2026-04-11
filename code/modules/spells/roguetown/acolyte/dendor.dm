// Druid
/obj/effect/proc_holder/spell/targeted/blesscrop
	name = "Bless Crops"
	desc = "Bless up to five crops around you. Revives dead plants, gives them nutrition and water if low and boosts their growth."
	range = 5
	overlay_state = "blesscrop"
	releasedrain = 30
	recharge_time = 30 SECONDS
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	max_targets = 0
	cast_without_targets = TRUE
	sound = 'sound/magic/churn.ogg'
	associated_skill = /datum/skill/magic/holy
	invocations = list("The Treefather commands thee, be fruitful!")
	invocation_type = "shout" //can be none, whisper, emote and shout
	miracle = TRUE
	devotion_cost = 20

/obj/effect/proc_holder/spell/targeted/blesscrop/cast(list/targets,mob/user = usr)
	. = ..()
	var/growed = FALSE
	var/amount_blessed = 0
	var/obj/item/alch/blessedseedpowder/blessed_seed_powder = user.get_active_held_item()
	if(!istype(blessed_seed_powder))
		blessed_seed_powder = null
	// Detect a held bucket or mortar containing holy water for log blessing
	var/obj/item/reagent_containers/water_container = null
	if(!blessed_seed_powder)
		var/obj/item/held = user.get_active_held_item()
		if(held?.reagents && (istype(held, /obj/item/reagent_containers/glass/bucket) || istype(held, /obj/item/reagent_containers/glass/mortar)))
			if(held.reagents.get_reagent_amount(/datum/reagent/water/holywater) >= 2)
				water_container = held
	for(var/obj/structure/soil/soil in view(4))
		soil.bless_soil()
		growed = TRUE
		amount_blessed++
		// Blessed only up to 5 crops
		if(amount_blessed >= 5)
			break
	if(amount_blessed < 5)
		for(var/obj/structure/flora/roguetree/tree in view(4, user))
			if(blessed_seed_powder && tree.reinvigorate_tree(user))
				growed = TRUE
				amount_blessed++
				if(blessed_seed_powder == user.get_active_held_item())
					qdel(blessed_seed_powder)
					blessed_seed_powder = null
				if(amount_blessed >= 5)
					break
			if(tree.bless_tree(user))
				growed = TRUE
				amount_blessed++
				if(amount_blessed >= 5)
					break
	if(amount_blessed < 5)
		for(var/obj/structure/flora/newtree/tree in view(4, user))
			if(tree.bless_tree(user))
				growed = TRUE
				amount_blessed++
				if(amount_blessed >= 5)
					break
	if(amount_blessed < 5 && water_container)
		for(var/obj/item/grown/log/tree/log in view(4, user))
			if(log.type != /obj/item/grown/log/tree)
				continue
			if(!log.lumber_amount || log.blessed)
				continue
			if(water_container.reagents.get_reagent_amount(/datum/reagent/water/holywater) < 2)
				break
			log.bless_log()
			water_container.reagents.remove_reagent(/datum/reagent/water/holywater, 2)
			growed = TRUE
			amount_blessed++
			if(amount_blessed >= 5)
				break
	if(growed)
		visible_message(span_green("[usr] blesses the nearby crops with Dendor's Favour!"))
	return growed

//At some point, this spell should Awaken beasts, allowing a ghost to possess them. Not for this PR though.
/obj/effect/proc_holder/spell/targeted/beasttame
	name = "Tame Beast"
	desc = "Tames a targeted saiga, chicken, cow, goat, volf or spider to be non hostile and tamed."
	range = 5
	overlay_state = "tamebeast"
	releasedrain = 30
	recharge_time = 30 SECONDS
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	max_targets = 0
	cast_without_targets = TRUE
	sound = 'sound/magic/churn.ogg'
	associated_skill = /datum/skill/magic/holy
	invocations = list("Be still and calm, brotherbeast.")
	invocation_type = "whisper" //can be none, whisper, emote and shout
	miracle = TRUE
	devotion_cost = 20
	var/beast_tameable_factions = list("saiga", "chickens", "cows", "goats", "wolfs", "spiders")

/obj/effect/proc_holder/spell/targeted/beasttame/cast(list/targets,mob/user = usr)
	. = ..()
	visible_message(span_green("[usr] soothes the beastblood with Dendor's whisper."))
	var/tamed = FALSE
	for(var/mob/living/simple_animal/hostile/retaliate/animal in get_hearers_in_view(2, usr))
		if((animal.mob_biotypes & MOB_UNDEAD))
			continue
		if(faction_check(animal.faction, beast_tameable_factions))
			animal.tamed(TRUE)
			animal.aggressive = FALSE
			if(animal.ai_controller)
				animal.ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
				animal.ai_controller.clear_blackboard_key(BB_BASIC_MOB_RETALIATE_LIST)
				animal.ai_controller.set_blackboard_key(BB_BASIC_MOB_TAMED, TRUE)
			to_chat(usr, "With Dendor's aide, you soothe [animal] of their anger.")
	return tamed

/obj/effect/proc_holder/spell/targeted/conjure_glowshroom
	name = "Fungal Illumination"
	desc = "Summons glowing mushrooms that shock people that try moving into them. Dendorites are immune."
	range = 1
	action_icon_state = "glowshroom"
	action_icon = 'icons/mob/actions/genericmiracles.dmi'
	overlay_state = "blesscrop"
	releasedrain = 30
	recharge_time = 30 SECONDS
	chargetime = 1 SECONDS
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	max_targets = 0
	cast_without_targets = TRUE
	sound = 'sound/items/dig_shovel.ogg'
	associated_skill = /datum/skill/magic/holy
	invocations = list("Treefather light the way.")
	invocation_type = "whisper" //can be none, whisper, emote and shout
	devotion_cost = 30

/obj/effect/proc_holder/spell/targeted/conjure_glowshroom/cast(list/targets, mob/user = usr)
	. = ..()

	to_chat(user, span_notice("I begin enriching the soil around me!"))
	if(!do_after(user, 0.5 SECONDS, progress = TRUE))
		revert_cast()
		return FALSE

	// 1x3 horizontal line: front, left of user, right of user.
	var/turf/target_turf = get_step(user, user.dir)
	var/turf/target_turf_two = get_step(user, turn(user.dir, 90))
	var/turf/target_turf_three = get_step(user, turn(user.dir, -90))
	for(var/turf/spawn_turf in list(target_turf, target_turf_two, target_turf_three))
		if(!isclosedturf(spawn_turf) && !locate(/obj/structure/glowshroom) in spawn_turf)
			new /obj/structure/glowshroom(spawn_turf)
	return TRUE

/obj/effect/proc_holder/spell/targeted/conjure_vines
	name = "Vine Sprout"
	desc = "Summon vines nearby."
	overlay_state = "blesscrop"
	releasedrain = 90
	invocations = list("Treefather, bring forth vines.")
	invocation_type = "shout"
	devotion_cost = 30
	range = 1
	recharge_time = 30 SECONDS
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	max_targets = 0
	cast_without_targets = TRUE
	sound = 'sound/items/dig_shovel.ogg'
	associated_skill = /datum/skill/magic/holy
	miracle = TRUE

/obj/effect/proc_holder/spell/targeted/conjure_vines/cast(list/targets, mob/user = usr)
	. = ..()
	var/turf/target_turf = get_step(user, user.dir)
	var/turf/target_turf_two = get_step(target_turf, turn(user.dir, 90))
	var/turf/target_turf_three = get_step(target_turf, turn(user.dir, -90))
	if(!locate(/obj/structure/vine/dendor) in target_turf)
		new /obj/structure/vine/dendor(target_turf)
	if(!locate(/obj/structure/vine/dendor) in target_turf_two)
		new /obj/structure/vine/dendor(target_turf_two)
	if(!locate(/obj/structure/vine/dendor) in target_turf_three)
		new /obj/structure/vine/dendor(target_turf_three)

	return TRUE

/obj/effect/proc_holder/spell/self/howl/call_of_the_moon
	name = "Call of the Moon"
	desc = "Draw upon the the secrets of the hidden firmament to converse with the mooncursed."
	overlay_state = "howl"
	antimagic_allowed = FALSE
	recharge_time = 600
	ignore_cockblock = TRUE
	use_language = TRUE
	var/first_cast = FALSE

/obj/effect/proc_holder/spell/self/howl/call_of_the_moon/cast(mob/living/carbon/human/user)
	// only usable at night
	if (!GLOB.tod == "night")
		to_chat(user, span_warning("I must wait for the hidden moon to rise before I may call upon it."))
		revert_cast()
		return
	// if they don't have beast language somehow, give it to them
	if (!user.has_language(/datum/language/beast))
		user.grant_language(/datum/language/beast)
		to_chat(user, span_boldnotice("The vestige of the hidden moon high above reveals His truth: the knowledge of beast-tongue was in me all along."))

	if (!first_cast)
		to_chat(user, span_boldwarning("So it is murmured in the Earth and Air: the Call of the Moon is sacred, and to share knowledge gleaned from it with those not of Him is a SIN."))
		to_chat(user, span_boldwarning("Ware thee well, child of Dendor."))
		first_cast = TRUE
	. = ..()

/obj/effect/proc_holder/spell/invoked/spiderspeak
	name = "Spider Speak"
	desc = "Makes spiders not attack the target."
	overlay_state = "tamebeast"
	releasedrain = 15
	chargedrain = 0
	chargetime = 1 SECONDS
	range = 2
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = 'sound/magic/churn.ogg'
	invocations = list("Spiders of Psydonia, allow me to pass safely!")
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	recharge_time = 4 SECONDS
	miracle = TRUE
	devotion_cost = 25

/obj/effect/proc_holder/spell/invoked/spiderspeak/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		user.visible_message("<font color='yellow'>[user] infuses [target] with swirling strands of spectral webs!</font>")
		target.visible_message("<font color='yellow'>You feel your tongue shift strangely, producing odd clicking noises.</font>")
		target.apply_status_effect(/datum/status_effect/buff/spider_speak)
		return TRUE
	revert_cast()
	return FALSE

// --- T4 Miracle: Sanctify Tree -----------------------------------------------
/obj/effect/proc_holder/spell/invoked/sanctify_tree
	name = "Sanctify Tree"
	desc = "Channel Dendor's most sacred blessing to consecrate a living, unburnt tree into a sanctified tree of the Treefather — a nexus of druidic power."
	invocation_type = "shout"
	overlay_state = "blesscrop"
	range = 1
	recharge_time = 60 SECONDS
	associated_skill = /datum/skill/magic/holy
	sound = 'sound/ambience/noises/mystical (4).ogg'
	invocations = list("Treefather, consecrate this living tree into your eternal embrace!")
	miracle = TRUE
	devotion_cost = 1000

/obj/effect/proc_holder/spell/invoked/sanctify_tree/cast(list/targets, mob/living/user)
	. = ..()

	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return FALSE

	var/atom/target_atom = targets[1]
	var/obj/structure/flora/newtree/target = null

	if(istype(target_atom, /obj/structure/flora/newtree) \
			&& !istype(target_atom, /obj/structure/flora/newtree/sanctified) \
			&& !target_atom.burnt)
		target = target_atom
	else if(target_atom.loc && (get_dist(user, target_atom.loc) <= 1))
		for(var/obj/structure/flora/newtree/NT in target_atom.loc)
			if(!istype(NT, /obj/structure/flora/newtree/sanctified) && !NT.burnt)
				target = NT
				break

	if(!target)
		to_chat(H, span_warning("I must target a living tree directly adjacent to me. Old trees, burnt trees, wise trees, and already-sanctified trees cannot be consecrated."))
		return FALSE

	H.visible_message(
		span_notice("[H] presses both hands to the bark of [target] and begins a long, reverent invocation."),
		span_notice("I press my hands to the bark and channel the Treefather's blessing into the tree...")
	)

	if(!do_after(H, 10 SECONDS, target = target))
		to_chat(H, span_warning("The consecration ritual was interrupted — the blessing fades & must be restarted."))
		return FALSE

	if(QDELETED(target) || target.burnt || istype(target, /obj/structure/flora/newtree/sanctified))
		to_chat(H, span_warning("The tree is no longer a valid target for sanctification."))
		return FALSE

	var/turf/T = get_turf(target)

	// Clean up branches and leaves from the old newtree.
	// Mirrors the wise tree conversion in create_wise_tree.dm.
	for(var/turf/adjacent in range(1, T))
		for(var/obj/structure/flora/newbranch/B in adjacent)
			qdel(B)
		for(var/obj/structure/flora/newleaf/L in adjacent)
			qdel(L)
	var/turf/above = get_step_multiz(T, UP)
	if(istype(above, /turf/open/transparent/openspace))
		for(var/obj/structure/flora/newtree/upper_tree in above)
			qdel(upper_tree)

	qdel(target)

	var/obj/structure/flora/roguetree/wise/sanctified/new_tree = new(T)
	playsound(T, 'sound/ambience/noises/mystical (4).ogg', 70, TRUE)
	H.visible_message(
		span_green("[H]'s hands blaze with golden light as [new_tree] is consecrated and transfigured into a sanctified tree of Dendor!"),
		span_notice("I feel the Treefather's power flow through me as [new_tree] is sanctified.")
	)
	SEND_SIGNAL(H, COMSIG_TREE_TRANSFORMED)
	return TRUE

//==============================================================================
// Soulbind & dryad control spells (granted by Cat 7 soulbind ritual)
//==============================================================================

/// Summon (or unsummon) a lesser dryad bound to this player.
/// First cast: spawns the lesser dryad adjacent to the caster and tags it.
/// Second cast (if already summoned): qdels the dryad, returning it to the grove.
/obj/effect/proc_holder/spell/targeted/summon_lesser_dryad
	name = "Summon Lesser Dryad"
	desc = "Call forth a lesser dryad from the grove to serve as your guardian. Cast again to send it back."
	overlay_state = "blesscrop"
	action_icon_state = "blessing"
	action_icon = 'icons/mob/actions/genericmiracles.dmi'
	releasedrain = 60
	recharge_time = 60 SECONDS
	chargetime = 1 SECONDS
	max_targets = 0
	cast_without_targets = TRUE
	associated_skill = /datum/skill/magic/holy
	invocations = list("Treefather, lend me your guardian.")
	invocation_type = "whisper"
	/// Reference to the currently summoned lesser dryad.
	var/mob/living/simple_animal/hostile/retaliate/rogue/fae/dryad/lesser/conjured_dryad = null

/obj/effect/proc_holder/spell/targeted/summon_lesser_dryad/cast(list/targets, mob/user = usr)
	. = ..()
	if(!istype(user, /mob/living/carbon/human))
		return FALSE
	var/mob/living/carbon/human/H = user

	// If already summoned, unsummon
	if(conjured_dryad && !QDELETED(conjured_dryad))
		conjured_dryad.visible_message(span_boldwarning("[conjured_dryad] dissolves back into the grove."))
		qdel(conjured_dryad)
		conjured_dryad = null
		to_chat(H, span_notice("My dryad returns to the grove."))
		return TRUE

	// Summon the lesser dryad
	var/turf/spawn_turf = null
	for(var/D in GLOB.alldirs)
		var/turf/adj = get_step(get_turf(H), D)
		if(adj && !isclosedturf(adj))
			spawn_turf = adj
			break
	if(!spawn_turf)
		to_chat(H, span_warning("There is no room to summon the dryad here."))
		revert_cast()
		return FALSE

	var/mob/living/simple_animal/hostile/retaliate/rogue/fae/dryad/lesser/D = new(spawn_turf, H)
	conjured_dryad = D
	// Register cleanup if the dryad dies on its own
	RegisterSignal(D, COMSIG_QDELETING, PROC_REF(on_dryad_deleted))
	to_chat(H, span_green("A lesser dryad emerges from the roots, answering my call."))
	D.visible_message(span_notice("[D] takes form beside [H]."))
	return TRUE

/obj/effect/proc_holder/spell/targeted/summon_lesser_dryad/proc/on_dryad_deleted(datum/source)
	conjured_dryad = null
	UnregisterSignal(source, COMSIG_QDELETING)

/// Triggers the lesser dryad's surge: kneestingers + 5×5 vines around it.
/// The player targets the dryad (or any turf near it) to activate the ability.
/obj/effect/proc_holder/spell/targeted/lesser_dryad_special
	name = "Dryad Surge"
	desc = "Command your lesser dryad to erupt with thorns and vines. The dryad must be within 10 tiles."
	overlay_state = "blesscrop"
	action_icon_state = "blessing"
	action_icon = 'icons/mob/actions/genericmiracles.dmi'
	releasedrain = 50
	recharge_time = 25 SECONDS
	chargetime = 0 SECONDS
	max_targets = 1
	cast_without_targets = FALSE
	associated_skill = /datum/skill/magic/holy
	invocations = list("Tangle my enemies and sting their feet. Grove, arise!")
	invocation_type = "shout"
	range = 10
	/// Reference back to the conjure spell so we can find the dryad.
	var/obj/effect/proc_holder/spell/targeted/summon_lesser_dryad/conjure_spell = null

/obj/effect/proc_holder/spell/targeted/lesser_dryad_special/cast(list/targets, mob/user = usr)
	. = ..()
	if(!istype(user, /mob/living/carbon/human))
		return FALSE
	var/mob/living/simple_animal/hostile/retaliate/rogue/fae/dryad/lesser/D = null
	// Find a lesser dryad owned by this player within range
	for(var/mob/living/simple_animal/hostile/retaliate/rogue/fae/dryad/lesser/dryad in view(10, user))
		if(dryad.conjurer_ckey == user.ckey)
			D = dryad
			break
	if(!D)
		to_chat(user, span_warning("My dryad is not nearby."))
		revert_cast()
		return FALSE
	if(!D.dryad_surge())
		to_chat(user, span_warning("My dryad's power has not yet recovered."))
		revert_cast()
		return FALSE
	return TRUE

/// Minion order subtype for controlling the lesser dryad faction.
/// Inherits all minion_order behavior, but only affects mobs tagged with the caster's faction.
/obj/effect/proc_holder/spell/invoked/minion_order/lesser_dryad
	name = "Order Dryad"
	desc = "Command your lesser dryad to move, follow, or attack. Cast on the dryad to toggle stance, on a turf to send it there, on yourself to have it follow, or on an enemy to have it attack."
	faction_ordering = FALSE

