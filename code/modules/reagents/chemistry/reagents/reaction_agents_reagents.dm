/datum/reagent/reaction_agent
	name = "Reaction Agent"
	description = "Привет! Я багнутый реагент. Пожалуйста, сообщите о моих преступлениях. Спасибо!!"

/datum/reagent/reaction_agent/intercept_reagents_transfer(datum/reagents/target, amount, copy_only)
	if(!target)
		return FALSE
	if(target.flags & NO_REACT)
		return FALSE
	if(target.has_reagent(/datum/reagent/stabilizing_agent))
		return FALSE
	if(!target.total_volume)
		return FALSE
	if(LAZYLEN(target.reagent_list) == 1)
		if(target.has_reagent(type)) //Allow dispensing into self
			return FALSE
	return TRUE

/datum/reagent/reaction_agent/acidic_buffer
	name = "Strong Acidic Buffer"
	description = "Этот реагент будет расходовать себя и сдвигать pH колбы в сторону кислотности при добавлении к другой."
	color = "#fbc314"
	ph = 0
	inverse_chem = null
	fallback_icon = 'icons/obj/drinks/drink_effects.dmi'
	fallback_icon_state = "acid_buffer_fallback"
	glass_price = DRINK_PRICE_HIGH

//Consumes self on addition and shifts ph
/datum/reagent/reaction_agent/acidic_buffer/intercept_reagents_transfer(datum/reagents/target, amount, copy_only)
	. = ..()
	if(!.)
		return

	//do the ph change
	var/message
	if(target.ph <= ph)
		message = "Колба пенится при добавлении буфера, но без эффекта."
	else
		message = "Колба пенится по мере изменения pH!"
		target.adjust_all_reagents_ph((-(amount / target.total_volume) * BUFFER_IONIZING_STRENGTH))
		target.update_total()

	//give feedback & remove from holder because it's not transferred
	target.my_atom.audible_message(span_warning(message))
	playsound(target.my_atom, 'sound/effects/chemistry/bufferadd.ogg', 50, TRUE)
	if(!copy_only)
		volume -= amount
		holder.update_total()

/datum/reagent/reaction_agent/basic_buffer
	name = "Strong Basic Buffer"
	description = "Этот реагент будет расходовать себя и сдвигать pH колбы в сторону щёлочности при добавлении к другой."
	color = "#3853a4"
	ph = 14
	inverse_chem = null
	fallback_icon = 'icons/obj/drinks/drink_effects.dmi'
	fallback_icon_state = "base_buffer_fallback"
	glass_price = DRINK_PRICE_HIGH

/datum/reagent/reaction_agent/basic_buffer/intercept_reagents_transfer(datum/reagents/target, amount, copy_only)
	. = ..()
	if(!.)
		return

	//do the ph change
	var/message
	if(target.ph >= ph)
		message = "Колба пенится при добавлении буфера, но без эффекта."
	else
		message = "Колба пенится по мере изменения pH!"
		target.adjust_all_reagents_ph(((amount / target.total_volume) * BUFFER_IONIZING_STRENGTH))
		target.update_total()

	//give feedback & remove from holder because it's not transferred
	target.my_atom.audible_message(span_warning(message))
	playsound(target.my_atom, 'sound/effects/chemistry/bufferadd.ogg', 50, TRUE)
	if(!copy_only)
		volume -= amount
		holder.update_total()

//purity testor/reaction agent prefactors

/datum/reagent/prefactor_a
	name = "Interim Product Alpha"
	description = "Этот реагент является префактором для реагента-тестера чистоты и будет реагировать со стабильной плазмой для его создания"
	color = "#bafa69"

/datum/reagent/prefactor_b
	name = "Interim Product Beta"
	description = "Этот реагент является префактором для реагента-агента скорости реакции и будет реагировать со стабильной плазмой для его создания"
	color = "#8a3aa9"

/datum/reagent/reaction_agent/purity_tester
	name = "Purity Tester"
	description = "Этот реагент будет расходовать себя и бурно реагировать, если в колбе присутствует сильно нечистый реагент."
	ph = 3
	color = "#ffffff"

/datum/reagent/reaction_agent/purity_tester/intercept_reagents_transfer(datum/reagents/target, amount, copy_only)
	. = ..()
	if(!.)
		return
	var/is_inverse = FALSE
	for(var/_reagent in target.reagent_list)
		var/datum/reagent/reaction_agent/reagent = _reagent
		if(reagent.purity <= reagent.inverse_chem_val)
			is_inverse = TRUE
	if(is_inverse)
		target.my_atom.audible_message(span_warning("Колба бурно пузырится при добавлении реагента!"))
		playsound(target.my_atom, 'sound/effects/chemistry/bufferadd.ogg', 50, TRUE)
	else
		target.my_atom.audible_message(span_warning("Добавленный реагент, кажется, мало что делает."))
	if(!copy_only)
		volume -= amount
		holder.update_total()

///How much the reaction speed is sped up by - for 5u added to 100u, an additional step of 1 will be done up to a max of 2x
#define SPEED_REAGENT_STRENGTH 20

/datum/reagent/reaction_agent/speed_agent
	name = "Tempomyocin"
	description = "Этот реагент будет расходовать себя и ускорять текущую реакцию, изменяя чистоту текущей реакции на свою собственную."
	ph = 10
	color = "#e61f82"

/datum/reagent/reaction_agent/speed_agent/intercept_reagents_transfer(datum/reagents/target, amount, copy_only)
	. = ..()
	if(!.)
		return FALSE
	if(!length(target.reaction_list))//you can add this reagent to a beaker with no ongoing reactions, so this prevents it from being used up.
		return FALSE
	amount /= target.reaction_list.len
	for(var/_reaction in target.reaction_list)
		var/datum/equilibrium/reaction = _reaction
		if(!reaction)
			CRASH("[_reaction] находится в списке реакций, но не является равновесием")
		var/power = (amount / reaction.target_vol) * SPEED_REAGENT_STRENGTH
		power *= creation_purity
		power = clamp(power, 0, 2)
		reaction.react_timestep(power, creation_purity)
	if(!copy_only)
		volume -= amount
		holder.update_total()

#undef SPEED_REAGENT_STRENGTH
