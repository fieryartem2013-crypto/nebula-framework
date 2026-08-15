# 🌌 Nebula Framework — Star Wars RP для Garry's Mod

Кастомный фреймворк для ролевых серверов во вселенной Звёздных Войн.
Вдохновлён **Helix Framework** и **Clockwork**, построен с нуля с фокусом на производительность и удобство кастомизации.

---

## 📋 Содержание

- [Установка](#-установка)
- [Структура проекта](#-структура-проекта)
- [Системы](#-системы)
- [Конфигурация](#-конфигурация)
- [Команды](#-команды)
- [Кастомизация](#-кастомизация)

---

## 🚀 Установка

1. Скопируйте папку `gamemodes/nebula` в директорию `garrysmod/gamemodes/`
2. Убедитесь что структура папок корректна
3. Запустите сервер с параметром `-gamemode nebula`
4. Или добавьте в `server.cfg`:
   ```
   gamemode nebula
   ```

---

## 📁 Структура проекта

```
nebula/
├── gamemode.txt                 # Описание гейммода
├── gamemode/
│   ├── shared.lua              # Точка входа (shared)
│   ├── core/
│   │   ├── sh_util.lua         # Утилиты
│   │   ├── sh_config.lua       # Система конфигурации
│   │   ├── sh_database.lua     # БД (shared)
│   │   ├── sv_database.lua     # БД (server) — SQLite
│   │   ├── sh_hooks.lua        # Хук-система
│   │   ├── sh_character.lua    # Персонажи (shared)
│   │   ├── sv_character.lua    # Персонажи (server)
│   │   └── cl_character.lua    # Персонажи (client)
│   ├── modules/
│   │   ├── sh_inventory.lua    # Инвентарь (shared)
│   │   ├── sv_inventory.lua    # Инвентарь (server)
│   │   ├── cl_inventory.lua    # Инвентарь (client)
│   │   ├── sh_factions.lua     # Фракции
│   │   ├── sh_economy.lua      # Экономика (shared)
│   │   ├── sv_economy.lua      # Экономика (server)
│   │   ├── sh_chat.lua         # Чат (shared)
│   │   ├── sv_chat.lua         # Чат (server)
│   │   ├── cl_chat.lua         # Чат (client)
│   │   └── sh_animation.lua    # Анимации
│   ├── derma/
│   │   ├── cl_fonts.lua        # Шрифты
│   │   ├── cl_theme.lua        # Тема оформления
│   │   ├── cl_inventory.lua    # UI инвентаря
│   │   ├── cl_character.lua    # UI персонажей
│   │   └── cl_hud.lua          # HUD
│   ├── schema/
│   │   └── sh_schema.lua       # Схема (предметы, настройки)
│   ├── player_class/
│   │   └── player_nebula.lua   # Класс игрока
│   └── entities/
│       └── entities/
│           └── nebula_item/    # Энтити предмета
│               ├── init.lua
│               ├── shared.lua
│               └── cl_init.lua
└── README.md
```

---

## ⚙️ Системы

### 👤 Система персонажей
- Создание/удаление/загрузка персонажей
- Максимум 3 персонажа (настраивается)
- Валидация имён (Имя Фамилия)
- Описание персонажа
- Выбор фракции и модели

### 🎒 Инвентарь
- Предметы с категориями, весом, стаками
- Использование, выброс, подбор с земли
- Уникальные предметы (только 1 в инвентаре)
- Стекуемые предметы
- Мирные предметы (энтити на земле)

### 🏛️ Фракции (Star Wars)
| Фракция | Описание |
|---------|----------|
| Galactic Empire | Империя с военной мощью |
| Rebel Alliance | Альянс повстанцев |
| Citizen | Обычные жители |
| Bounty Hunters' Guild | Охотники за головами |
| Smugglers' Guild | Контрабандисты |
| Mandalorian Clan | Мандалорцы |

### 💰 Экономика
- Валюта: Credits (CR)
- Стартовые деньги: 500 CR
- Зарплаты по фракциям
- Автоматические выплаты
- Переводы между игроками
- Лимит: 10M CR

### 💬 Чат-система
| Команда | Тип | Дальность |
|---------|-----|-----------|
| `/me` или `*` | Действие | 500 units |
| `/y` или `!` | Крик | 1000 units |
| `/w` | Шёпот | 150 units |
| `/r` | Радио | Фракция |
| `//` или `((` | LOOC | 500 units |
| `/a` | Админ | Глобально |

### 🎭 Анимации
| Анимация | Описание |
|----------|----------|
| `/sit` | Сесть |
| `/wave` | Помахать |
| `/salute` | Салют |
| `/surrender` | Сдаться |
| `/dance` | Танец |
| `/bow` | Поклон |
| `/kneel` | На колени |

---

## 🔧 Конфигурация

Все настройки хранятся в `data/nebula/config.json` и управляются через `Nebula.config`.

### Ключевые настройки

| Ключ | Значение по умолчанию | Описание |
|------|----------------------|----------|
| `server_name` | Nebula Star Wars RP | Название сервера |
| `max_characters` | 3 | Макс. персонажей |
| `starting_credits` | 500 | Стартовые деньги |
| `currency_name` | Credits | Название валюты |
| `currency_symbol` | CR | Символ валюты |
| `salary_interval` | 300 | Интервал зарплат (сек) |
| `chat_range` | 500 | Дальность IC чата |
| `walk_speed` | 180 | Скорость ходьбы |
| `run_speed` | 280 | Скорость бега |

---

## 🎮 Команды (консоль)

| Команда | Описание | Права |
|---------|----------|-------|
| `nebula_char_reload [player]` | Перезагрузить персонажа | Admin |
| `nebula_char_saveall` | Сохранить всех | Admin |
| `nebula_give_money <player> <amount>` | Выдать деньги | Admin |
| `nebula_set_money <player> <amount>` | Установить деньги | SuperAdmin |

---

## 🎨 Кастомизация

### Добавление новой фракции

В `schema/sh_schema.lua`:

```lua
Nebula.faction:Register("custom_faction", {
    name = "Custom Faction",
    description = "Описание фракции",
    color = Color(255, 100, 0),
    model = "models/player/...",
    weapons = {"weapon_pistol"},
    items = {"custom_id"},
    health = 100,
    armor = 50,
    salary = 100,
    classes = {
        {id = "trooper", name = "Trooper", salary = 80},
    },
})
```

### Добавление нового предмета

```lua
Nebula.inventory:RegisterItem("custom_item", {
    name = "Custom Item",
    description = "Описание предмета",
    model = "models/...",
    category = "Category",
    weight = 1.0,
    stackable = true,
    maxStack = 5,
    usable = true,
    useText = "Use",
    onUse = function(ply, item)
        -- Логика использования
        return true -- true = потратить предмет
    end,
})
```

### Добавление новой анимации

```lua
Nebula.animation:Register("custom_anim", {
    name = "Custom Animation",
    description = "Описание",
    sequenceName = "animation_sequence",
    duration = 3, -- 0 = бесконечно
    movement = false,
})
```

### Добавление нового типа чата

```lua
Nebula.chat:RegisterType("custom", {
    name = "Custom",
    color = Color(255, 200, 100),
    range = 300,
    format = "%s: [%s]",
})
```

---

## 🔌 Хуки (для плагинов)

| Хук | Аргументы | Описание |
|-----|-----------|----------|
| `Nebula:CharacterLoaded` | `ply, charID` | Персонаж загружен |
| `Nebula:CharacterCreated` | `ply, charID, data` | Персонаж создан |
| `Nebula:CharacterDeleted` | `ply, charID` | Персонаж удалён |
| `Nebula:InventoryChanged` | `ply, action, itemID, itemData` | Инвентарь изменён |
| `Nebula:MoneyChanged` | `ply, old, new, reason` | Деньги изменены |
| `Nebula:FactionChanged` | `ply, old, new` | Фракция изменена |
| `Nebula:PlayerDataLoaded` | `ply` | Данные игрока загружены |

---

## 📝 Лицензия

MIT License — используйте как хотите!

---

**Nebula Framework v1.0.0** — Создано с ❤️ для сообщества Star Wars RP
