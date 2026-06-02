/obj/effect/decal/cleanable/roguerune/zizo
	name = "sigil"
	desc = "Ominous carvings that exude a maleficent presence."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "sigil"
	runesize = 1
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32
	var/zizorituals = list("Grand Gathering")

/proc/iscabalist(mob/living/carbon/human/A)
	return istype(A) && A.mind && (A.mind.has_antag_datum(/datum/antagonist/cabalist)) // are they a cabalist?

/obj/effect/decal/cleanable/roguerune/zizo/attack_hand(mob/living/user)
	if(!iscabalist(user))
		to_chat(user, span_cult("WHY DID I TOUCH IT? HER GAZE IS SURELY UPON ME NOW!"))
		return
	var/ritualselection = input(user, "DARK RITES", src) as null|anything in zizorituals
	switch(ritualselection)
		if("Grand Gathering")
			var/onrune = view(1, loc)
			var/list/cultistsonrune = list()
			for(var/mob/living/carbon/human/persononrune in onrune)
				if(iscabalist(persononrune))
					cultistsonrune += persononrune
			// if(cultistsonrune.len <= 2) // don't forget to ignore this if theres less than 3 cabalists alive in the world
			// 	to_chat(user, span_cult("I need at least two other faithfuls with me if I ever hope to attract Her attention."))
			if(cultistsonrune.len > 0) // dont forget to this to > 2
				if(!do_after(user, 5 SECONDS))
					return
				if(!cultistsonrune.len > 0)
					to_chat(user, span_cult("Someone got off the rune. I can't continue the ritual."))
					return
				for(var/mob/living/carbon/human/H in cultistsonrune)
					H.Immobilize(15 SECONDS) // Can't move once you've started
					H.say("ZIZO! ZIZO! DAME OF PROGRESS!!")
				if(!do_after(user, 5 SECONDS))
					return
				if(!cultistsonrune.len > 0)
					to_chat(user, span_cult("Someone got off the rune. I can't continue the ritual."))
					return
				for(var/mob/living/carbon/human/H in cultistsonrune)
					H.say("ZIZO! ZIZO! HEAR OUR CALL!!")
				if(!do_after(user, 5 SECONDS))
					return
				if(!cultistsonrune.len > 0)
					to_chat(user, span_cult("Someone got off the rune. I can't continue the ritual."))
					return
				for(var/mob/living/carbon/human/H in cultistsonrune)
					H.say("ZIZO! ZIZO! GRANT US YOUR WILL!!")
				if(!do_after(user, 5 SECONDS))
					return
				to_chat(GLOB.cabalists, span_userdanger("[user] has initiated the grand gathering! You feel ZIZO's will enter your mind..."))
