/datum/modpack/cyrillic_fixes
	name = "Поддержка кириллицы"
	desc = "Добавляет поддержку кириллицы."
	author = "larentoun, Bizzonium"


/// Добавлена глобальная таблица преобразования русских букв в латинские для keybindings
/// Создает статичное сопоставление русских символов (ЙЦУКЕН) с латинскими (QWERTY)
/// Используется для корректной работы горячих клавиш при русской раскладке
GLOBAL_LIST_INIT(ru_key_to_en_key, list(
	"й" = "q", "ц" = "w", "у" = "e", "к" = "r", "е" = "t", "н" = "y", "г" = "u", "ш" = "i", "щ" = "o", "з" = "p", "х" = "\[", "ъ" = "]",
	"ф" = "a", "ы" = "s", "в" = "d", "а" = "f", "п" = "g", "р" = "h", "о" = "j", "л" = "k", "д" = "l", "ж" = ";", "э" = "'",
	"я" = "z", "ч" = "x", "с" = "c", "м" = "v", "и" = "b", "т" = "n", "ь" = "m", "б" = ",", "ю" = "."
))

/// Функция конвертации русских клавиш в латинские аналоги
/// Принимает символ, возвращает соответствующий символ из QWERTY-раскладки
/// Сохраняет регистр: русская "Ф" → латинская "A", русская "ф" → латинская "a"
/proc/convert_ru_key_to_en_key(var/_key)
	var/new_key = lowertext(_key)
	new_key = GLOB.ru_key_to_en_key[new_key]
	if(!new_key)
		return _key
	return uppertext(new_key)

/// Максимальное количество слотов для горячих клавиш
#define MAX_HOTKEY_SLOTS 3

/// Обработчик установки keybindings с поддержкой кириллицы
/// 1. Проверяет существование привязки по имени
/// 2. Валидирует входные данные (массив горячих клавиш)
/// 3. Конвертирует русские символы через convert_ru_key_to_en_key()
/// 4. Обновляет keybindings у клиента
/datum/preference_middleware/keybindings/set_keybindings(list/params, mob/user)
	var/keybind_name = params["keybind_name"]

	if (isnull(GLOB.keybindings_by_name[keybind_name]))
		return FALSE

	var/list/raw_hotkeys = params["hotkeys"]
	if (!istype(raw_hotkeys))
		return FALSE

	if (raw_hotkeys.len > MAX_HOTKEY_SLOTS)
		return FALSE

	// В BYOND нет оптимального и простого способа проверить, является ли что-то массивом.
	// А не объектом в BYOND, поэтому просто санируйте его, чтобы убедиться в этом.
	var/list/hotkeys = list()
	for (var/hotkey in raw_hotkeys)
		if (!istext(hotkey))
			return FALSE

		// Достаточно произвольное число, просто чтобы не сохранять огромные фальшивые привязки клавиш.
		if (length(hotkey) > 100)
			return FALSE

		hotkeys += convert_ru_key_to_en_key(hotkey)

	preferences.key_bindings[keybind_name] = hotkeys
	preferences.key_bindings_by_key = preferences.get_key_bindings_by_key(preferences.key_bindings)

	user.client.update_special_keybinds()

	return TRUE

#undef MAX_HOTKEY_SLOTS

/// Модификация ввода keycombo с поддержкой кириллицы
/// Перехватывает ввод в TGUI-окне и конвертирует русские символы перед обработкой
/datum/tgui_input_keycombo/set_entry(entry)
	entry = convert_ru_key_to_en_key(entry) || entry
	. = ..()
