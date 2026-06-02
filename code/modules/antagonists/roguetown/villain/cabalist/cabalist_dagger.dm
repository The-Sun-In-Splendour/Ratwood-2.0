/obj/item/rogueweapon/huntingknife/idagger/silver/arcyne/zizo // CABALIST only item. Lets them draw sigils. DO NOT LOSE IT.
	name = "avantyne dagger"
	desc = ""
	icon_state = "zdagger"
	sheathe_icon = "sdagger"
	force = 25
	max_integrity = 250
	max_blade_int = 300
	picklvl = 1.2
	is_silver = FALSE
	smeltresult = /obj/item/ingot/steel

/obj/item/rogueweapon/huntingknife/idagger/silver/arcyne/zizo/ComponentInitialize() // so it can't be blessed by the ten
    return

/obj/item/rogueweapon/huntingknife/idagger/silver/arcyne/zizo/examine(mob/user) // FIX THIS. DOESNT WORK!!!
	. = ..()
	if(user.mind.has_antag_datum(/datum/antagonist/cabalist))
		desc = "Made of bleeding avantyne. An unholy jab at the world.<br>This dagger was given to me upon my induction, only with this can I draw Her sigils. I should keep it safe, as replacing it will be costly."
	else
		desc = "Made of bleeding avantyne. An unholy jab at the world."

/obj/item/rogueweapon/huntingknife/idagger/silver/arcyne/zizo/attack_self(mob/living/carbon/human/user) // this is just arcyne silver dagger code without all the unnecessary things.
	if(!iscabalist(user))
		return
	var/turf/Turf = get_turf(user)
	var/structures_in_way = check_for_structures_and_closed_turfs(loc, /obj/effect/decal/cleanable/roguerune/zizo)
	var/crafttime = 100
	if(locate(/obj/effect/decal/cleanable/roguerune) in Turf)
		to_chat(user, span_cult("There is already a rune here."))
		return
	if(structures_in_way)
		to_chat(user, span_cult("There is a structure, rune or wall in the way."))
		return
	user.visible_message(span_notice("[user] starts to carve profane symbols with [user.p_their()] [name]."), \
		span_notice("I start to drag the blade in the shape of symbols and sigils."))
	playsound(loc, 'sound/magic/bladescrape.ogg', 100, TRUE)
	if(do_after(user, crafttime, target = src))
		user.visible_message(
			span_warning("[user] carves a profane sigil with [user.p_their()] [name]!"), \
			span_notice("I finish dragging the blade in symbols and circles, leaving behind a sigil of ZIZO.")
		)
		new /obj/effect/decal/cleanable/roguerune/zizo(Turf)
