///Returns whether or not a player is a guest using their ckey as an input
/proc/is_guest_key(key)
	if(findtext(key, "Guest-", 1, 7) != 1) //was findtextEx
		return FALSE

	var/i, ch, len = length(key)

	for(i = 7, i <= len, ++i) //we know the first 6 chars are Guest-
		ch = text2ascii(key, i)
		if (ch < 48 || ch > 57) //0-9
			return FALSE
	return TRUE

/// Proc that just logs whenever an uninitialized client tries to do something before they have fully gone through New().
/// Intended to be used in conjunction with the `VALIDATE_CLIENT_INITIALIZATION()` macro, but can be dropped anywhere when we look at the `fully_created` var on /client.
/proc/unvalidated_client_error(client/target)
	to_chat(target, span_warning("Вы ещё не полностью инициализированы! Пожалуйста, подождите."))
	log_access("Клиент [key_name(target)] попытался выполнить команду до завершения инициализации.")
