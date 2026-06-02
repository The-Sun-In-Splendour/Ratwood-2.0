GLOBAL_LIST_EMPTY(cabalists)
var/grandgathered = 0
var/list/cabalobjectives = list()

/datum/antagonist/cabalist/proc/generateobjectives()
	

/datum/antagonist/cabalist
	name = "Cabalist"
	roundend_category = "cabalists"
	antagpanel_category = "The Cabal"
	job_rank = ROLE_CABALIST
	confess_lines = list(
		"MY LYFE FOR THE CABAL!",
		"THE WORLD WILL END IN THREE YILS AND FOUR MONTHS!",
		"PROGRESS COMES FOR ALL!"
	)
	rogue_enabled = TRUE

	var/traits_cabalist = list(
		TRAIT_STEELHEARTED,
		TRAIT_HERESIARCH,
		TRAIT_EMPATH, // seeing ppl freak out when you call to zizo is funny
		TRAIT_CABALIST
		)

/datum/antagonist/cabalist/examine_friendorfoe(datum/antagonist/examined_datum,mob/examiner,mob/examined)
	if(istype(examined_datum, /datum/antagonist/cabalist))
		return span_boldred("A fellow cabalist. It's us against the world.")

/datum/antagonist/cabalist/on_gain()
	. = ..()
	owner.special_role = ROLE_CABALIST
	owner.special_items["Avantyne Dagger"] = /obj/item/rogueweapon/huntingknife/idagger/silver/arcyne/zizo
	if(owner.current)
		owner.current.verbs |= /mob/living/carbon/human/proc/calltozizo
		owner.current.verbs |= /mob/living/carbon/human/proc/listfaithful
	for (var/trait in traits_cabalist)
		ADD_TRAIT(owner.current, trait, "[type]")
	owner.current.adjust_skillrank_up_to(/datum/skill/combat/knives, SKILL_LEVEL_EXPERT, TRUE) // serial killer build
	GLOB.cabalists += owner.current
	greet()
	return ..()

/datum/antagonist/cabalist/greet()
	if(owner.current)
		to_chat(owner.current, span_notice("I am a member of the local cabal. I should find my fellow faithful and accomplish Her Great Work.<br><i>Draw a sigil on the floor with your <b>Avantyne Dagger</b>, gather your fellow cabalists upon it and call out to ZIZO to hear Her will.</i>"))
	return ..()
