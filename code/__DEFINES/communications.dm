/// Время, в течение которого админ может отменить межсекторное сообщение
#define CROSS_SECTOR_CANCEL_TIME (10 SECONDS)

/// Расширенное время, в течение которого админ может отменить межсекторное сообщение, если проходит фильтр, например
#define EXTENDED_CROSS_SECTOR_CANCEL_TIME (30 SECONDS)

//Уровни безопасности влияют на таймер шаттла побега
/// Уровень безопасности зелёный.
#define SEC_LEVEL_GREEN 0
/// Уровень безопасности синий.
#define SEC_LEVEL_BLUE 1
/// Уровень безопасности красный.
#define SEC_LEVEL_RED 2

/// ANDROMEDA ADDITION START
/// Уровень безопасности гамма.
#define SEC_LEVEL_GAMMA 3
/// Уровень безопасности эпсилон.
#define SEC_LEVEL_EPSILON 4
/// ANDROMEDA ADDITION END

/// Уровень безопасности дельта.
#define SEC_LEVEL_DELTA 5
