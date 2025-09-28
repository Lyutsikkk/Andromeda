GLOBAL_DATUM(everyone_an_antag, /datum/everyone_is_an_antag_controller)

ADMIN_VERB(secrets, R_NONE, "Секрет", "Злоупотребляйте сильнее, чем когда-либо, с помощью этого удобного меню.", ADMIN_CATEGORY_GAME)
	var/datum/secrets_menu/tgui = new(user)
	tgui.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("Панель Секрет")

/datum/secrets_menu
	var/client/holder //client of whoever is using this datum
	var/is_debugger = FALSE
	var/is_funmin = FALSE

/datum/secrets_menu/New(user)//user can either be a client or a mob due to byondcode(tm)
	if (istype(user, /client))
		var/client/user_client = user
		holder = user_client //if its a client, assign it to holder
	else
		var/mob/user_mob = user
		holder = user_mob.client //if its a mob, assign the mob's client to holder

	is_debugger = check_rights(R_DEBUG)
	is_funmin = check_rights(R_FUN)

/datum/secrets_menu/ui_state(mob/user)
	return ADMIN_STATE(R_NONE)

/datum/secrets_menu/ui_close()
	qdel(src)

/datum/secrets_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Secrets")
		ui.open()

/datum/secrets_menu/ui_data(mob/user)
	var/list/data = list()
	data["is_debugger"] = is_debugger
	data["is_funmin"] = is_funmin
	return data

#define THUNDERDOME_TEMPLATE_FILE "admin_thunderdome.dmm"
#define HIGHLANDER_DELAY_TEXT "40 секунд (разрушить надежду на обычную смену)"
/datum/secrets_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if((action != "admin_log" || action != "show_admins") && !check_rights(R_ADMIN))
		return
	switch(action)
		//Generic Buttons anyone can use.
		if("admin_log")
			var/dat
			for(var/l in GLOB.admin_activities)
				dat += "<li>[l]</li>"
			if(!GLOB.admin_activities.len)
				dat += "В этом раунде никто ничего не сделал!"
			var/datum/browser/browser = new(holder, "admin_log", "Логи Администратора", 600, 500)
			browser.set_content(dat)
			browser.open()
		if("show_admins")
			var/dat
			if(GLOB.admin_datums)
				for(var/ckey in GLOB.admin_datums)
					var/datum/admins/D = GLOB.admin_datums[ckey]
					dat += "[ckey] - [D.rank_names()]<br>"
				var/datum/browser/browser = new(holder, "showadmins", "Текущие администраторы", 600, 500)
				browser.set_content(dat)
				browser.open()
		//Buttons for debug.
		if("maint_access_engiebrig")
			if(!is_debugger)
				return
			for(var/obj/machinery/door/airlock/maintenance/doors as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock/maintenance))
				if ((ACCESS_MAINT_TUNNELS in doors.req_access) || (ACCESS_MAINT_TUNNELS in doors.req_one_access))
					doors.req_access = list()
					doors.req_one_access = list(ACCESS_BRIG, ACCESS_ENGINEERING)
			message_admins("[key_name_admin(holder)] сделал все двери техтоннелей доступными только для инженерного отдела и брига.")
		if("maint_access_brig")
			if(!is_debugger)
				return
			for(var/obj/machinery/door/airlock/maintenance/doors as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock/maintenance))
				if ((ACCESS_MAINT_TUNNELS in doors.req_access) || (ACCESS_MAINT_TUNNELS in doors.req_one_access))
					doors.req_access = list(ACCESS_BRIG)
					doors.req_one_access = list()
			message_admins("[key_name_admin(holder)] сделал все двери техтоннелей доступными только для брига.")
		if("infinite_sec")
			if(!is_debugger)
				return
			var/datum/job/sec_job = SSjob.get_job_type(/datum/job/security_officer)
			sec_job.total_positions = -1
			sec_job.spawn_positions = -1
			message_admins("[key_name_admin(holder)] убрал ограничение на количество офицеров безопасности.")

		//Buttons for helpful stuff. This is where people land in the tgui
		if("clear_virus")
			var/choice = tgui_alert(usr, "Вы уверены, что хотите вылечить все болезни? Это также даст иммунитет к этим болезням",, list("Да", "Отмена"))
			if(choice == "Да")
				message_admins("[key_name_admin(holder)] вылечил все болезни.")
				for(var/thing in SSdisease.active_diseases)
					var/datum/disease/D = thing
					D.cure()

		if("list_bombers")
			holder.holder.list_bombers()

		if("list_signalers")
			holder.holder.list_signalers()

		if("list_lawchanges")
			holder.holder.list_law_changes()

		if("showailaws")
			holder.holder.list_law_changes()

		if("manifest")
			holder.holder.show_manifest()

		if("dna")
			holder.holder.list_dna()

		if("fingerprints")
			holder.holder.list_fingerprints()

		if("ctfbutton")
			toggle_id_ctf(holder, CTF_GHOST_CTF_GAME_ID)

		if("tdomereset")
			var/delete_mobs = tgui_alert(usr, "Очистить всех мобов?", "Сброс Громодрома", list("Да", "Нет", "Отмена"))
			if(!delete_mobs || delete_mobs == "Отмена")
				return

			log_admin("[key_name(holder)] сбросил громодром к стандарту с delete_mobs помеченным как [delete_mobs].")
			message_admins(span_adminnotice("[key_name_admin(holder)] сбросил громодром к стандарту с delete_mobs помеченным как [delete_mobs]."))

			var/area/thunderdome = GLOB.areas_by_type[/area/centcom/tdome/arena]
			if(delete_mobs == "Yes")
				for(var/mob/living/mob in thunderdome)
					qdel(mob) //Clear mobs
			for(var/obj/obj in thunderdome)
				if(!istype(obj, /obj/machinery/camera))
					qdel(obj) //Clear objects

			var/datum/map_template/thunderdome_template = SSmapping.map_templates[THUNDERDOME_TEMPLATE_FILE]
			thunderdome_template.should_place_on_top = FALSE
			var/turf/thunderdome_corner = locate(thunderdome.x - 3, thunderdome.y - 1, 1) // have to do a little bit of coord manipulation to get it in the right spot
			thunderdome_template.load(thunderdome_corner)

		if("set_name")
			var/new_name = input(holder, "Пожалуйста, введите новое название для станции.", "Что?", "") as text|null
			if(!new_name)
				return
			set_station_name(new_name)
			log_admin("[key_name(holder)] переименовал станцию в \"[new_name]\".")
			message_admins(span_adminnotice("[key_name_admin(holder)] переименовал станцию в: [new_name]."))
			priority_announce("[command_name()] переименовал станцию в \"[new_name]\".")
		if("reset_name")
			var/confirmed = tgui_alert(usr,"Вы уверены, что хотите сбросить название станции?", "Подтверждение", list("Да", "Нет", "Отмена"))
			if(confirmed != "Да")
				return
			var/new_name = new_station_name()
			set_station_name(new_name)
			log_admin("[key_name(holder)] сбросил название станции.")
			message_admins(span_adminnotice("[key_name_admin(holder)] сбросил название станции."))
			priority_announce("[command_name()] переименовал станцию в \"[new_name]\".")
		if("night_shift_set")
			var/val = tgui_alert(holder, "Что вы хотите установить для ночной смены? Это переопределит автоматическую систему до тех пор, пока не будет установлено значение автоматически.", "Ночная Смена", list("Вкл", "Выкл", "Авто"))
			switch(val)
				if("Авто")
					if(CONFIG_GET(flag/enable_night_shifts))
						SSnightshift.can_fire = TRUE
						SSnightshift.fire()
					else
						SSnightshift.update_nightshift(active = FALSE, announce = TRUE, forced = TRUE)
				if("Вкл")
					SSnightshift.can_fire = FALSE
					SSnightshift.update_nightshift(active = TRUE, announce = TRUE, forced = TRUE)
				if("Выкл")
					SSnightshift.can_fire = FALSE
					SSnightshift.update_nightshift(active = FALSE, announce = TRUE, forced = TRUE)
		if("moveferry")
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Отправить Паром ЦентКома"))
			if(!SSshuttle.toggleShuttle("ferry","ferry_home","ferry_away"))
				message_admins("[key_name_admin(holder)] переместил паром ЦентКома")
				log_admin("[key_name(holder)] переместил паром ЦентКома")
		if("togglearrivals")
			var/obj/docking_port/mobile/arrivals/A = SSshuttle.arrivals
			if(A)
				var/new_perma = !A.perma_docked
				A.perma_docked = new_perma
				SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Постоянная стыковка шаттла прибытия", "[new_perma ? "Включена" : "Выключена"]"))
				message_admins("[key_name_admin(holder)] [new_perma ? "остановил" : "запустил"] шаттл прибытия")
				log_admin("[key_name(holder)] [new_perma ? "остановил" : "запустил"] шаттл прибытия")
			else
				to_chat(holder, span_admin("Шаттла прибытия не существует."), confidential = TRUE)
		if("movelaborshuttle")
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Отправить Рабочий Шаттл"))
			if(!SSshuttle.toggleShuttle("laborcamp","laborcamp_home","laborcamp_away"))
				message_admins("[key_name_admin(holder)] переместил рабочий шаттл")
				log_admin("[key_name(holder)] переместил рабочий шаттл")
		//!fun! buttons.
		if("virus")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Вспышка Вируса"))
			var/datum/round_event_control/event
			var/prompt = tgui_alert(usr, "Какую систему болезней вы хотите?", "Настройка Болезни", list("Продвинутая", "Простая", "Создать Свою"))
			switch(prompt)
				if("Создать Свою")
					AdminCreateVirus(holder)
				if("Продвинутая")
					event = locate(/datum/round_event_control/disease_outbreak/advanced) in SSevents.control
				if("Простая")
					event = locate(/datum/round_event_control/disease_outbreak) in SSevents.control
			if(isnull(event))
				return
			if(length(event.admin_setup))
				for(var/datum/event_admin_setup/admin_setup_datum as anything in event.admin_setup)
					if(admin_setup_datum.prompt_admins() == ADMIN_CANCEL_EVENT)
						return
			event.run_event(admin_forced = TRUE)
			message_admins("[key_name_admin(usr)] запустил событие. ([event.name])")
			log_admin("[key_name(usr)] запустил событие. ([event.name])")

		if("allspecies")
			if(!is_funmin)
				return
			var/result = input(holder, "Пожалуйста, выберите новый вид","Вид") as null|anything in sortTim(GLOB.species_list, GLOBAL_PROC_REF(cmp_text_asc))
			if(result)
				SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Массовая Смена Вида", "[result]"))
				log_admin("[key_name(holder)] превратил всех людей в [result]")
				message_admins("\blue [key_name_admin(holder)] превратил всех людей в [result]")
				var/newtype = GLOB.species_list[result]
				for(var/i in GLOB.human_list)
					var/mob/living/carbon/human/H = i
					H.set_species(newtype)
		if("power")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Питание Всех ЛКП"))
			log_admin("[key_name(holder)] включил питание во всех зонах")
			message_admins(span_adminnotice("[key_name_admin(holder)] включил питание во всех зонах"))
			power_restore()
		if("unpower")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Отключение Всех ЛКП"))
			log_admin("[key_name(holder)] отключил питание во всех зонах")
			message_admins(span_adminnotice("[key_name_admin(holder)] отключил питание во всех зонах"))
			power_failure()
		if("quickpower")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Питание Всех СМЭС"))
			log_admin("[key_name(holder)] включил питание всех СМЭС")
			message_admins(span_adminnotice("[key_name_admin(holder)] включил питание всех СМЭС"))
			power_restore_quick()
		if("anon_name")
			if(!is_funmin)
				return
			holder.anon_names()
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Анонимные Имена"))
		if("tripleAI")
			if(!is_funmin)
				return
			holder.triple_ai()
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Тройной ИИ"))
		if("onlyone")
			if(!is_funmin)
				return
			var/response = tgui_alert(usr,"Задержать на 40 секунд?", "Может быть, в самом деле, только один", list("Мгновенно!", HIGHLANDER_DELAY_TEXT))
			switch(response)
				if("Мгновенно!")
					holder.only_one()
				if(HIGHLANDER_DELAY_TEXT)
					holder.only_one_delayed()
				else
					return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Может Быть Только Один"))
		if("guns")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Призвать Оружие"))
			var/survivor_probability = 0
			switch(tgui_alert(usr,"Хотите ли вы создать антагонистов выживших?",,list("Без Антагов","Некоторые Антаги","Все Антаги!")))
				if("Некоторые Антаги")
					survivor_probability = 25
				if("Все Антаги!")
					survivor_probability = 100

			summon_guns(holder.mob, survivor_probability)

		if("magic")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Призвать Магию"))
			var/survivor_probability = 0
			switch(tgui_alert(usr,"Хотите ли вы создать антагонистов-магов?",,list("Без Антагов","Некоторые Антаги","Все Антаги!")))
				if("Некоторые Антаги")
					survivor_probability = 25
				if("Все Антаги!")
					survivor_probability = 100

			summon_magic(holder.mob, survivor_probability)

		if("towerOfBabel")
			if(!is_funmin)
				return
			if(tgui_alert(usr,"Хотите ли вы рандомизировать язык для всех?",,list("Да","Нет")) == "Да")
				SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Вавилонская башня"))
				holder.tower_of_babel()

		if("cureTowerOfBabel")
			if(!is_funmin)
				return
			holder.tower_of_babel_undo()

		if("events")
			if(!is_funmin)
				return
			if(SSevents.wizardmode)
				switch(tgui_alert(usr,"Что вы хотите сделать?",,list("Усилить Призыв Событий","Выключить Призыв Событий","Ничего")))
					if("Усилить Призыв Событий")
						summon_events(holder)
						SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Призыв Событий", "Усиление"))
					if("Выключить Призыв Событий")
						SSevents.toggleWizardmode()
						SSevents.resetFrequency()
						SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Призыв Событий", "Отключение"))
			else
				if(tgui_alert(usr,"Хотите включить призыв событий?",,list("Да","Нет")) == "Да")
					summon_events(holder)
					SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Призыв Событий", "Активация"))

		if("eagles")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Эгалитарная Станция"))
			for(var/obj/machinery/door/airlock/airlock as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock))
				var/airlock_area = get_area(airlock)
				if(
					is_station_level(airlock.z) && \
					!istype(airlock_area, /area/station/command) && \
					!istype(airlock_area, /area/station/commons) && \
					!istype(airlock_area, /area/station/service) && \
					!istype(airlock_area, /area/station/command/heads_quarters) && \
					!istype(airlock_area, /area/station/security/prison) \
				)
					airlock.req_access = list()
					airlock.req_one_access = list()
			message_admins("[key_name_admin(holder)] активировал режим Эгалитарной Станции")
			priority_announce("Активирован удалённый контроль шлюзов ЦентКома. Пожалуйста, воспользуйтесь этим временем, чтобы познакомиться с коллегами.", null, SSstation.announcer.get_rand_report_sound())
		if("ancap")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Анархо-капиталистическая Станция"))
			SSeconomy.full_ancap = !SSeconomy.full_ancap
			message_admins("[key_name_admin(holder)] переключил режим Анархо-капитализма")
			if(SSeconomy.full_ancap)
				priority_announce("Анархо-капитализм теперь в полной силе.", null, SSstation.announcer.get_rand_report_sound())
			else
				priority_announce("Анархо-капитализм отменён.", null, SSstation.announcer.get_rand_report_sound())
		if("send_shuttle_back")
			if (!is_funmin)
				return
			if (SSshuttle.emergency.mode != SHUTTLE_ESCAPE)
				to_chat(usr, span_warning("Аварийный шаттл в настоящее время не в пути!"), confidential = TRUE)
				return
			var/make_announcement = tgui_alert(usr, "Сделать объявление от ЦентКома?", "Возврат аварийного шаттла", list("Да", "Свой текст", "Нет")) || "Нет"
			var/announcement_text = "Траектория аварийного шаттла переопределена, перенаправляем курс обратно на [station_name()]."
			if (make_announcement == "Свой текст")
				announcement_text = tgui_input_text(usr, "Собственное объявление ЦентКома", "Возврат аварийного шаттла", multiline = TRUE) || announcement_text
			var/new_timer = tgui_input_number(usr, "Как долго шаттл должен оставаться в пути?", "Когда мы высаживаемся, парни?", 180, 600)
			if (isnull(new_timer) || SSshuttle.emergency.mode != SHUTTLE_ESCAPE)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Вернуть Шаттл Назад"))
			message_admins("[key_name_admin(holder)] вернул шаттл эвакуации обратно на станцию")
			if (make_announcement != "Нет")
				priority_announce(
					text = announcement_text,
					title = "Переопределение траектории шаттла",
					sound =  'sound/announcer/announcement/announce_dig.ogg',
					sender_override = "Диспетчерская Флота",
					color_override = "grey",
				)
			SSshuttle.emergency.timer = INFINITY
			if (new_timer > 0)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(return_escape_shuttle), make_announcement), new_timer SECONDS)
			else
				INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(return_escape_shuttle), make_announcement)
		if("blackout")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Сломать Все Лампы"))
			message_admins("[key_name_admin(holder)] сломал все лампы")
			for(var/obj/machinery/light/L as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/light))
				L.break_light_tube()
				CHECK_TICK
		if("whiteout")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Починить Все Лампы"))
			message_admins("[key_name_admin(holder)] починил все лампы")
			for(var/obj/machinery/light/L as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/light))
				L.fix()
				CHECK_TICK
		if("customportal")
			if(!is_funmin)
				return

			var/list/settings = list(
				"mainsettings" = list(
					"typepath" = list("desc" = "Путь для спавна", "type" = "datum", "path" = "/mob/living", "subtypesonly" = TRUE, "value" = /mob/living/basic/bee),
					"humanoutfit" = list("desc" = "Экипировка если человек", "type" = "datum", "path" = "/datum/outfit", "subtypesonly" = TRUE, "value" = /datum/outfit),
					"amount" = list("desc" = "Количество на портал", "type" = "number", "value" = 1),
					"portalnum" = list("desc" = "Общее количество порталов", "type" = "number", "value" = 10),
					"offerghosts" = list("desc" = "Предложить призракам играть за мобов", "type" = "boolean", "value" = "Нет"),
					"minplayers" = list("desc" = "Минимальное количество призраков", "type" = "number", "value" = 1),
					"playersonly" = list("desc" = "Спавнить только мобов под контролем призраков", "type" = "boolean", "value" = "Нет"),
					"ghostpoll" = list("desc" = "Вопрос опроса призраков", "type" = "string", "value" = "Хотите ли вы играть за %TYPE% захватчика из портала?"),
					"delay" = list("desc" = "Время между порталами, в децисекундах", "type" = "number", "value" = 50),
					"color" = list("desc" = "Цвет портала", "type" = "color", "value" = COLOR_VIBRANT_LIME),
					"playlightning" = list("desc" = "Проигрывать звуки молнии при объявлении", "type" = "boolean", "value" = "Да"),
					"announce_players" = list("desc" = "Сделать объявление", "type" = "boolean", "value" = "Да"),
					"announcement" = list("desc" = "Объявление", "type" = "string", "value" = "Обнаружена масштабная блюспейс аномалия на пути к %STATION%. Приготовьтесь к столкновению."),
				)
			)

			message_admins("[key_name(holder)] создает пользовательский портальный шторм...")
			var/list/pref_return = present_pref_like_picker(holder, "Настроить Портальный Шторм", "Настроить Портальный Шторм", width = 600, timeout = 0, settings = settings)

			if (pref_return["button"] != 1)
				return

			var/list/prefs = settings["mainsettings"]

			if (prefs["amount"]["value"] < 1 || prefs["portalnum"]["value"] < 1)
				to_chat(holder, span_warning("Количество порталов и мобов для спавна должно быть не менее 1."), confidential = TRUE)
				return

			var/mob/path_to_spawn = prefs["typepath"]["value"]
			if (!ispath(path_to_spawn))
				path_to_spawn = text2path(path_to_spawn)

			if (!ispath(path_to_spawn))
				to_chat(holder, span_notice("Неверный путь [path_to_spawn]."), confidential = TRUE)
				return

			var/list/candidates = list()

			if (prefs["offerghosts"]["value"] == "Да")
				candidates = SSpolling.poll_ghost_candidates(replacetext(prefs["ghostpoll"]["value"], "%TYPE%", initial(path_to_spawn.name)), check_jobban = ROLE_TRAITOR, alert_pic = path_to_spawn, role_name_text = "портальный шторм")
				if (length(candidates) < prefs["minplayers"]["value"])
					message_admins("Недостаточно игроков записалось для создания портального шторма, минимум был [prefs["minplayers"]["value"]] а количество записавшихся [length(candidates)]")
					return

			if (prefs["announce_players"]["value"] == "Да")
				portal_announce(prefs["announcement"]["value"], (prefs["playlightning"]["value"] == "Да" ? TRUE : FALSE))

			var/list/storm_appearances = list()
			for(var/offset in 0 to SSmapping.max_plane_offset)
				var/mutable_appearance/storm = mutable_appearance('icons/obj/machines/engine/energy_ball.dmi', "energy_ball_fast", FLY_LAYER)
				SET_PLANE_W_SCALAR(storm, ABOVE_GAME_PLANE, offset)
				storm.color = prefs["color"]["value"]
				storm_appearances += storm

			message_admins("[key_name_admin(holder)] создал пользовательский портальный шторм, который создаст [prefs["portalnum"]["value"]] порталов, каждый из которых заспавнит [prefs["amount"]["value"]] [path_to_spawn]")
			log_admin("[key_name(holder)] создал пользовательский портальный шторм, который создаст [prefs["portalnum"]["value"]] порталов, каждый из которых заспавнит [prefs["amount"]["value"]] [path_to_spawn]")

			var/outfit = prefs["humanoutfit"]["value"]
			if (!ispath(outfit))
				outfit = text2path(outfit)

			for (var/i in 1 to prefs["portalnum"]["value"])
				if (length(candidates)) // если мы спавним игроков, нужно быть немного хитрее и не спавнить игроков поверх НПС
					var/ghostcandidates = list()
					for (var/j in 1 to min(prefs["amount"]["value"], length(candidates)))
						ghostcandidates += pick_n_take(candidates)
						addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(do_portal_spawn), get_random_station_turf(), path_to_spawn, length(ghostcandidates), storm_appearances, ghostcandidates, outfit), i * prefs["delay"]["value"])
				else if (prefs["playersonly"]["value"] != "Да")
					addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(do_portal_spawn), get_random_station_turf(), path_to_spawn, prefs["amount"]["value"], storm_appearances, null, outfit), i * prefs["delay"]["value"])

		if("changebombcap")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Лимит Бомб"))

			var/newBombCap = input(holder,"Каким должен быть новый лимит бомб. (вводится как радиус лёгких повреждений (третье число в общей нотации (1,2,3))) Должен быть выше 4)", "Новый Лимит Бомб", GLOB.MAX_EX_LIGHT_RANGE) as num|null
			if (!CONFIG_SET(number/bombcap, newBombCap))
				return

			message_admins(span_boldannounce("[key_name_admin(holder)] изменил лимит бомб на [GLOB.MAX_EX_DEVESTATION_RANGE], [GLOB.MAX_EX_HEAVY_RANGE], [GLOB.MAX_EX_LIGHT_RANGE]"))
			log_admin("[key_name(holder)] изменил лимит бомб на [GLOB.MAX_EX_DEVESTATION_RANGE], [GLOB.MAX_EX_HEAVY_RANGE], [GLOB.MAX_EX_LIGHT_RANGE]")
		if("department_cooldown_override") //Происходит при нажатии кнопки, создаёт значение для GLOB.department_cd_override в dept_order.dm
			if(!is_debugger)
				return
			if(isnull(GLOB.department_cd_override))
				var/set_override = tgui_input_number(usr, "Какой вы хотите установить кулдаун для заказов консоли?","Переопределение Кулдауна", 5)
				if(isnull(set_override))
					return //пользователь нажал отмену
				GLOB.department_cd_override = set_override
			else
				var/choice = tgui_alert(usr, "Переопределение активно. Вы можете изменить кулдаун или завершить переопределение.", "Вы пытались переопределить...", list("Переопределить", "Завершить Переопределение", "Отмена"))
				if(choice == "Переопределить")
					var/set_override = tgui_input_number(usr, "Какой вы хотите установить кулдаун для заказов консоли?", "Заголовок", 5)
					GLOB.department_cd_override = set_override
					return
				if(choice == "Завершить Переопределение")
					var/set_override = null
					GLOB.department_cd_override = set_override
					return
				if(!choice || choice == "Отмена")
					return
		//buttons that are fun for exactly you and nobody else.
		if("monkey")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Обезьянизировать Всех Людей"))
			message_admins("[key_name_admin(holder)] превратил всех в обезьян.")
			log_admin("[key_name_admin(holder)] превратил всех в обезьян.")
			for(var/i in GLOB.human_list)
				var/mob/living/carbon/human/H = i
				INVOKE_ASYNC(H, TYPE_PROC_REF(/mob/living/carbon, monkeyize))
		if("antag_all")
			if(!is_funmin)
				return
			if(!SSticker.HasRoundStarted())
				tgui_alert(usr,"Игра ещё не началась!")
				return
			if(GLOB.everyone_an_antag)
				var/are_we_antagstacking = tgui_alert(usr, "Секрет 'все антагонисты' уже был активирован. Хотите ли вы добавить ещё антагов?", "ОПАСНАЯ ЗОНА. Вы уверены в этом?", list("Подтвердить", "Отмена"))
				if(are_we_antagstacking != "Подтвердить")
					return

			var/chosen_antag = tgui_input_list(usr, "Выберите антагониста", "Выбор антагониста", list(ROLE_TRAITOR, ROLE_CHANGELING, ROLE_HERETIC, ROLE_CULTIST, ROLE_NINJA, ROLE_WIZARD, ROLE_NIGHTMARE))
			if(!chosen_antag)
				return
			var/objective = tgui_input_text(usr, "Введите цель", "Цель")
			if(!objective)
				return
			var/confirmation = tgui_alert(usr, "Превратить всех в [chosen_antag] с целью: [objective]", "Вы уверены в этом?", list("Подтвердить", "Отмена"))
			if(confirmation != "Подтвердить")
				return
			var/keep_generic_objecives = tgui_alert(usr, "Генерировать обычные цели?", "Дать стандартные цели?", list("Да", "Нет"))
			keep_generic_objecives = (keep_generic_objecives != "Да") ? FALSE : TRUE

			GLOB.everyone_an_antag = new /datum/everyone_is_an_antag_controller(chosen_antag, objective, keep_generic_objecives)
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("[chosen_antag] Все", "[objective]"))
			for(var/mob/living/player in GLOB.player_list)
				GLOB.everyone_an_antag.make_antag(null, player)
			message_admins(span_adminnotice("[key_name_admin(holder)] использовал секрет 'все антагонисты'. Антагонист: [chosen_antag]. Цель: [objective]. Генерировать стандартные цели: [keep_generic_objecives]"))
			log_admin("[key_name(holder)] использовал секрет 'все антагонисты': [chosen_antag]. Цель: [objective]. Генерировать стандартные цели: [keep_generic_objecives].")
		if("massbraindamage")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Массовое Повреждение Мозга"))
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				to_chat(H, span_bolddanger("Вы внезапно почувствовали себя глупее."), confidential = TRUE)
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60, 80)
			message_admins("[key_name_admin(holder)] нанес всем повреждение мозга")
		if("floorlava")
			SSweather.run_weather(/datum/weather/floor_is_lava)
		if("anime")
			if(!is_funmin)
				return
			var/animetype = tgui_alert(usr,"Хотите изменить одежду?",,list("Да","Нет","Отмена"))

			var/droptype
			if(animetype == "Да")
				droptype = tgui_alert(usr,"Сделать униформы невыбрасываемыми?",,list("Да","Нет","Отмена"))

			if(animetype == "Отмена" || droptype == "Отмена")
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Китайские Мультики"))
			message_admins("[key_name_admin(holder)] сделал всё кавайным.")
			for(var/i in GLOB.human_list)
				var/mob/living/carbon/human/H = i
				SEND_SOUND(H, sound(SSstation.announcer.event_sounds[ANNOUNCER_ANIMES]))

				if(H.dna.species.id == SPECIES_HUMAN)
					if(H.dna.features[FEATURE_TAIL] == "Ничего" || H.dna.features[FEATURE_EARS] == "Ничего")
						var/obj/item/organ/ears/cat/ears = new
						var/obj/item/organ/tail/cat/tail = new
						ears.Insert(H, movement_flags = DELETE_IF_REPLACED)
						tail.Insert(H, movement_flags = DELETE_IF_REPLACED)
					var/list/honorifics = list("[MALE]" = list("кун"), "[FEMALE]" = list("тян"), "[NEUTER]" = list("сан"), "[PLURAL]" = list("сан")) //Джон Рабуст -> Рабуст-кун
					var/list/names = splittext(H.real_name," ")
					var/forename = names.len > 1 ? names[2] : names[1]
					var/newname = "[forename]-[pick(honorifics["[H.gender]"])]"
					H.fully_replace_character_name(H.real_name,newname)
					H.update_body_parts()
					if(animetype == "Да")
						var/seifuku = pick(typesof(/obj/item/clothing/under/costume/seifuku))
						var/obj/item/clothing/under/costume/seifuku/I = new seifuku
						var/olduniform = H.w_uniform
						H.temporarilyRemoveItemFromInventory(H.w_uniform, TRUE, FALSE)
						H.equip_to_slot_or_del(I, ITEM_SLOT_ICLOTHING)
						qdel(olduniform)
						if(droptype == "Да")
							ADD_TRAIT(I, TRAIT_NODROP, ADMIN_TRAIT)
				else
					to_chat(H, span_warning("Ты недостаточно кавайный для этого!"), confidential = TRUE)
		if("masspurrbation")
			if(!is_funmin)
				return
			mass_purrbation()
			message_admins("[key_name_admin(holder)] посадил всех на \
				пурибацию!")
			log_admin("[key_name(holder)] посадил всех на пурибацию.")
		if("massremovepurrbation")
			if(!is_funmin)
				return
			mass_remove_purrbation()
			message_admins("[key_name_admin(holder)] снял всех с \
				пурибации.")
			log_admin("[key_name(holder)] снял всех с пурибации.")
		if("massimmerse")
			if(!is_funmin)
				return
			mass_immerse()
			message_admins("[key_name_admin(holder)] Полностью Погрузил \
				всех!")
			log_admin("[key_name(holder)] Полностью Погрузил всех.")
		if("unmassimmerse")
			if(!is_funmin)
				return
			mass_immerse(remove=TRUE)
			message_admins("[key_name_admin(holder)] Снял Полное Погружение \
				со всех!")
			log_admin("[key_name(holder)] Снял Полное Погружение со всех.")
		if("makeNerd")
			var/spawnpoint = pick(GLOB.blobstart)
			var/list/mob/dead/observer/candidates
			var/mob/dead/observer/chosen_candidate
			var/mob/living/basic/drone/nerd
			var/teamsize

			teamsize = input(usr, "Сколько дронов?", "Размер команды N.E.R.D.", 2) as num|null

			if(teamsize <= 0)
				return FALSE

			candidates = SSpolling.poll_ghost_candidates("Хотите ли вы быть рассмотренным в качестве [span_notice("аварийного дрона Нанотрейзен")]?", check_jobban = ROLE_DRONE, alert_pic = /mob/living/basic/drone/classic, role_name_text = "аварийный дрон Нанотрейзен")

			if(length(candidates) == 0)
				return FALSE

			while(length(candidates) && teamsize)
				chosen_candidate = pick(candidates)
				candidates -= chosen_candidate
				nerd = new /mob/living/basic/drone/classic(spawnpoint)
				nerd.PossessByPlayer(chosen_candidate.key)
				nerd.log_message("был выбран в качестве аварийного дрона Нанотрейзен.", LOG_GAME)
				teamsize--

			return TRUE
		if("ctf_instagib")
			if(!is_funmin)
				return
			if(GLOB.ctf_games.len <= 0)
				tgui_alert(usr, "Нет настроенных CTF игр.")
				return
			var/selected_game = tgui_input_list(usr, "Выберите CTF игру для изменения.", "Режим Instagib", GLOB.ctf_games)
			if(isnull(selected_game))
				return
			var/datum/ctf_controller/ctf_controller = GLOB.ctf_games[selected_game]
			var/choice = tgui_alert(usr, "[ctf_controller.instagib_mode ? "Вернуться к стандартному" : "Включить instagib"] режиму?", "Режим Instagib", list("Да", "Нет"))
			if(choice != "Да")
				return
			ctf_controller.toggle_instagib_mode()
			message_admins("[key_name_admin(holder)] [ctf_controller.instagib_mode ? "включил" : "выключил"] режим instagib в CTF игре: [selected_game]")
			log_admin("[key_name_admin(holder)] [ctf_controller.instagib_mode ? "включил" : "выключил"] режим instagib в CTF игре: [selected_game]")

		if("mass_heal")
			if(!is_funmin)
				return
			var/heal_mobs = tgui_alert(usr, "Исцелить всех мобов и вернуть призраков в их тела?", "Массовое Исцеление", list("Да", "Нет"))
			if(!heal_mobs || heal_mobs != "Да")
				return

			for(var/mob/dead/observer/ghost in GLOB.player_list) //Вернуть всех призраков, если возможно
				if(!ghost.mind || !ghost.mind.current) //ничего не произойдет, если нет тела
					continue
				ghost.reenter_corpse()

			for(var/mob/living/player in GLOB.player_list)
				player.revive(ADMIN_HEAL_ALL, force_grab_ghost = TRUE)

			sound_to_playing_players('sound/effects/pray_chaplain.ogg')
			message_admins("[key_name_admin(holder)] исцелил всех.")
			log_admin("[key_name(holder)] исцелил всех.")

	if(holder)
		log_admin("[key_name(holder)] использовал секрет: [action].")
#undef THUNDERDOME_TEMPLATE_FILE
#undef HIGHLANDER_DELAY_TEXT

/proc/portal_announce(announcement, playlightning)
	set waitfor = FALSE
	if (playlightning)
		sound_to_playing_players('sound/effects/magic/lightning_chargeup.ogg')
		sleep(8 SECONDS)
	priority_announce(replacetext(announcement, "%STATION%", station_name()))
	if (playlightning)
		sleep(2 SECONDS)
		sound_to_playing_players('sound/effects/magic/lightningbolt.ogg')

/// Spawns a portal storm that spawns in sentient/non sentient mobs
/// portal_appearance is a list in the form (turf's plane offset + 1) -> appearance to use
/proc/do_portal_spawn(turf/loc, mobtype, numtospawn, list/portal_appearance, players, humanoutfit)
	for (var/i in 1 to numtospawn)
		var/mob/spawnedMob = new mobtype(loc)
		if (length(players))
			var/mob/chosen = players[1]
			if (chosen.client)
				chosen.client.prefs.safe_transfer_prefs_to(spawnedMob, is_antag = TRUE)
				spawnedMob.PossessByPlayer(chosen.key)
			players -= chosen
		if (ishuman(spawnedMob) && ispath(humanoutfit, /datum/outfit))
			var/mob/living/carbon/human/H = spawnedMob
			H.equipOutfit(humanoutfit)
	var/turf/T = get_step(loc, SOUTHWEST)
	T.flick_overlay_static(portal_appearance[GET_TURF_PLANE_OFFSET(T) + 1], 15)
	playsound(T, 'sound/effects/magic/lightningbolt.ogg', rand(80, 100), TRUE)

/// Docks the emergency shuttle back to the station and resets its state
/proc/return_escape_shuttle(make_announcement)
	if (SSshuttle.emergency.initiate_docking(SSshuttle.getDock("emergency_home"), force = TRUE) != DOCKING_SUCCESS)
		message_admins("Аварийный шаттл не смог пристыковаться обратно к станции!")
		SSshuttle.emergency.timer = 1 // Предотвращает софтлоки
		return
	if (make_announcement != "Нет")
		priority_announce(
			text = "[SSshuttle.emergency] вернулся на станцию.",
			title = "Переопределение аварийного шаттла",
			sound = ANNOUNCER_SHUTTLEDOCK,
			sender_override = "Диспетчерская Флота",
			color_override = "grey",
		)
	SSshuttle.emergency.mode = SHUTTLE_IDLE
	SSshuttle.emergency.timer = 0
	// Docks the pods back (don't ask about physics)
	for (var/obj/docking_port/mobile/pod/pod in SSshuttle.mobile_docking_ports)
		if (pod.previous)
			pod.initiate_docking(pod.previous, force = TRUE)

/datum/everyone_is_an_antag_controller
	var/chosen_antag = ""
	var/objective = ""
	var/keep_generic_objecives

/datum/everyone_is_an_antag_controller/New(chosen_antag, objective, keep_generic_objecives)
	. = ..()
	src.chosen_antag = chosen_antag
	src.objective = objective
	src.keep_generic_objecives = keep_generic_objecives
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(make_antag_delay))

/datum/everyone_is_an_antag_controller/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)
	return ..()

/datum/everyone_is_an_antag_controller/proc/assign_admin_objective_and_antag(mob/living/player, datum/antagonist/antag_datum)
	var/datum/objective/new_objective = new(objective)
	new_objective.team = player
	new_objective.team_explanation_text = objective
	antag_datum.objectives += new_objective
	player.mind.add_antag_datum(antag_datum)

/datum/everyone_is_an_antag_controller/proc/make_antag_delay(datum/source, mob/living/player)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(make_antag), source, player)


/datum/everyone_is_an_antag_controller/proc/make_antag(datum/source, mob/living/player)
	if(player.stat == DEAD || !player.mind)
		return
	sleep(1)
	if(ishuman(player))
		switch(chosen_antag)
			if(ROLE_TRAITOR)
				var/datum/antagonist/traitor/antag_datum = new(give_objectives = keep_generic_objecives)
				assign_admin_objective_and_antag(player, antag_datum)
				var/datum/uplink_handler/uplink = antag_datum.uplink_handler
				uplink.has_progression = FALSE
			if(ROLE_CHANGELING)
				var/datum/antagonist/changeling/antag_datum = new
				antag_datum.give_objectives = keep_generic_objecives
				assign_admin_objective_and_antag(player, antag_datum)
			if(ROLE_HERETIC)
				var/datum/antagonist/heretic/antag_datum = new
				antag_datum.give_objectives = keep_generic_objecives
				assign_admin_objective_and_antag(player, antag_datum)
			if(ROLE_CULTIST)
				var/datum/antagonist/cult/antag_datum = new
				assign_admin_objective_and_antag(player, antag_datum)
			if(ROLE_NINJA)
				var/datum/antagonist/ninja/antag_datum = new
				antag_datum.give_objectives = keep_generic_objecives
				for(var/obj/item/item_to_drop in player)
					if(!istype(item_to_drop, /obj/item/implant)) //avoid removing implanted uplinks
						player.dropItemToGround(item_to_drop, FALSE)
				assign_admin_objective_and_antag(player, antag_datum)
			if(ROLE_WIZARD)
				var/datum/antagonist/wizard/antag_datum = new
				antag_datum.give_objectives = keep_generic_objecives
				antag_datum.move_to_lair = FALSE
				for(var/obj/item/item_to_drop in player) //avoid deleting player's items
					if(!istype(item_to_drop, /obj/item/implant))
						player.dropItemToGround(item_to_drop, FALSE)
				assign_admin_objective_and_antag(player, antag_datum)
			if(ROLE_NIGHTMARE)
				var/datum/antagonist/nightmare/antag_datum = new
				assign_admin_objective_and_antag(player, antag_datum)
				player.set_species(/datum/species/shadow/nightmare)

	else if(isAI(player))
		var/datum/antagonist/malf_ai/antag_datum = new
		antag_datum.give_objectives = keep_generic_objecives
		assign_admin_objective_and_antag(player, antag_datum)
