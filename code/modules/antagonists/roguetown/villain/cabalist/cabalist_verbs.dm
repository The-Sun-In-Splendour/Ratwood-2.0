/mob/living/carbon/human/proc/calltozizo()
	set name = "CALL TO ZIZO"
	set category = "Cabalist"
	src.say("ZIZO! ZIZO! ZIZO!")

/mob/living/carbon/human/proc/listfaithful()
	set name = "LIST FAITHFUL"
	set category = "Cabalist"
	to_chat(src, span_notice("You remember your brothers and sisters in faith..."))
	for(var/mob/living/carbon/human/H in GLOB.cabalists)
		var/cabalistclass = H.get_class_title()
		to_chat(src, span_notice("[H] - [cabalistclass]"))
