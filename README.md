# 🌌 Nebula Framework v1.1.0

**RP Framework for Garry's Mod**

> *Архитектура: Helix + Clockwork*

---

## 📖 Описание

Nebula Framework — модульный RP фреймворк для Garry's Mod, вдохновлённый архитектурой **Helix** и **Clockwork**.

Создан для быстрого создания ролевых серверов любой тематики.

---

## 🏗️ Архитектура

```
gamemodes/nebula/
├── shared.lua              — точка входа
├── core/                   — ядро (13 файлов)
│   ├── sh_util.lua         — утилиты
│   ├── sh_config.lua       — конфигурация
│   ├── sh_database.lua     — БД (SQLite)
│   ├── sh_character.lua    — система персонажей
│   ├── sh_permissions.lua  — ранги и права
│   ├── sh_convars.lua      — ConVar система
│   ├── sh_safety.lua       — pcall защита
│   ├── sh_spawn.lua        — спавн-поинты
│   ├── sh_hotreload.lua    — hot-reload модулей
│   ├── sh_logger.lua       — логирование
│   ├── sh_antispam.lua     — антиспам
│   └── sv_admin.lua        — админ-команды
├── modules/                — модули (18 файлов)
│   ├── sh_inventory.lua    — инвентарь
│   ├── sh_factions.lua     — фракции
│   ├── sh_economy.lua      — экономика
│   ├── sh_chat.lua         — чат-система
│   ├── sh_animation.lua    — анимации
│   ├── sh_npc.lua          — NPC система
│   ├── sh_quest.lua        — квесты
│   ├── sh_craft.lua        — крафт
│   └── sh_build.lua        — постройки
└── derma/                  — UI (7 файлов)
    ├── cl_fonts.lua        — шрифты
    ├── cl_theme.lua        — тема
    ├── cl_hud.lua          — HUD
    ├── cl_admin.lua        — админ-панель (F3)
    └── cl_inventory.lua    — UI инвентаря
```

---

## ⚙️ Модули

| Модуль | Описание | Файлы |
|--------|----------|-------|
| **Database** | SQLite, автосейв, кэш | 2 |
| **Character** | Создание, загрузка, валидация | 3 |
| **Inventory** | Предметы, стаки, мирные предметы | 3 |
| **Factions** | Фракции, классы, лоадауты | 1 |
| **Economy** | Валюта, зарплаты, переводы | 2 |
| **Chat** | IC, OOC, LOOC, шёпот, крик, радио | 3 |
| **Animation** | 12+ анимаций | 1 |
| **NPC** | Торговцы, диалоги, квестодатели | 2 |
| **Quest** | Цепочки, прогресс, награды | 2 |
| **Craft** | Рецепты, станции, шанс успеха | 2 |
| **Build** | Баррикады, лимиты, возврат ресурсов | 2 |
| **Permissions** | 6 рангов, 12 прав | 1 |
| **Admin** | F3 панель, команды | 2 |

---

## 🔧 ConVar (настройки)

```
nebula_max_characters 3      — макс персонажей
nebula_starting_money 500    — стартовые деньги
nebula_walk_speed 180        — скорость ходьбы
nebula_run_speed 280         — скорость бега
nebula_chat_range 500        — дальность чата
nebula_salary_interval 300   — интервал зарплат
nebula_death_penalty 5       — штраф при смерти %
nebula_debug 0               — уровень дебага
```

---

## 🎮 Команды

| Команда | Описание | Права |
|---------|----------|-------|
| `nebula_tp <player>` | Телепорт к игроку | Moderator |
| `nebula_bring <player>` | Телепорт к себе | Moderator |
| `nebula_kick <player> <reason>` | Кик | Moderator |
| `nebula_give_item <player> <item>` | Выдать предмет | Admin |
| `nebula_setrank <steamid> <rank>` | Установить ранг | Admin |
| `nebula_errors` | Просмотр ошибок | Admin |
| `nebula_reload <module>` | Hot-reload модуля | SuperAdmin |

---

## 📊 Статистика

| | |
|---|---|
| Файлов | 45 Lua |
| Строк | 6,887 |
| Модулей | 12 |
| ConVar | 15 |
| Рангов | 6 |
| Прав | 12 |

---

## 🔗 GitHub

- **Фреймворк:** https://github.com/fieryartem2013-crypto/nebula-framework
- **Сервер (пример):** https://github.com/fieryartem2013-crypto/quarantine-rp

---

**Nebula Framework v1.1.0** — Helix + Clockwork Architecture
