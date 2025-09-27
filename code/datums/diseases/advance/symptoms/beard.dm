/** Гипертрихоз лица
 * Не влияет на скрытность.
 * Повышает устойчивость.
 * Увеличивает скорость.
 * Слегка повышает заразность.
 * Высокий уровень.
 * Бонус: Заставляет моба отрастить густую бороду, независимо от пола.
*/

/datum/symptom/beard
	name = "Гипертрихоз лица"
	desc = "Вирус значительно ускоряет рост волос, вызывая быстрое отрастание бороды."
	illness = "Бородач"
	stealth = 0
	resistance = 3
	stage_speed = 2
	transmittable = 1
	level = 4
	severity = 1
	symptom_delay_min = 18
	symptom_delay_max = 36

	var/list/beard_order = list("Борода (Дженсен)", "Борода (Полная)", "Борода (Дварф)", "Борода (Очень длинная)")

/datum/symptom/beard/Activate(datum/disease/advance/disease)
	. = ..()
	if(!.)
		return

	var/mob/living/manly_mob = disease.affected_mob
	if(ishuman(manly_mob))
		var/mob/living/carbon/human/manly_man = manly_mob
		var/index = min(max(beard_order.Find(manly_man.facial_hairstyle)+1, disease.stage-1), beard_order.len)
		if(index > 0 && manly_man.facial_hairstyle != beard_order[index])
			to_chat(manly_man, span_warning("Ваш подбородок чешется."))
			manly_man.set_facial_hairstyle(beard_order[index], update = TRUE)
