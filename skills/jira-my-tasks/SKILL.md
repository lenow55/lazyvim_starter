---
name: jira-my-tasks
description: Проверяет задачи в Jira, назначенные на текущего пользователя. Используй, когда пользователь просит: показать мои задачи в Jira, что мне назначено, мои открытые задачи, что у меня в работе в джире, проверить Jira, список моих задач.
---

# Jira My Tasks Skill

Этот скилл предназначен для получения и отображения задач Jira, назначенных на текущего пользователя (currentUser()), с фильтрацией по статусу, приоритету и проекту.

## Когда использовать

Триггеры:

- "проверь задачи в Jira"
- "покажи мои задачи в Jira"
- "что мне назначено в Jira"
- "мои открытые задачи"
- "что у меня в работе"
- "список моих задач Jira"
- "jira my tasks"
- "tasks assigned to me"

## MCP инструменты

Используется MCP сервер `mcp-atlassian` и его инструмент `jira_search`.

## Алгоритм работы

### Шаг 1: Получить активные задачи

Вызови `jira_search` со следующим JQL:

```
assignee = currentUser() AND resolution = Unresolved ORDER BY priority DESC, updated DESC
```

Параметры:

- `jql`: запрос выше
- `fields`: `summary,status,priority,issuetype,assignee,reporter,updated,created,duedate,labels,project`
- `limit`: 50 (максимум, чтобы получить полный список)

### Шаг 2: Дополнительная фильтрация

⚠️ **Важно**: На некоторых инсталляциях Jira (включая jira.lanit.ru) `resolution = Unresolved` может возвращать как активные, так и завершённые задачи. Поэтому после получения результатов **отфильтруй вручную** по статусу:

**Исключить** задачи со статусом в категории "Выполнено" / "Done":

- "Закрыт"
- "Closed"
- "Canceled"
- "Done"
- "Resolved"
- "Выполнено"
- и любые другие, попадающие в категорию `category.name == "Выполнено"` или `"Done"`

Если `total` после фильтрации больше 0, и пользователь не уточнил проект — продолжи с полным списком.

### Шаг 3: Группировка и вывод

Сгруппируй задачи по приоритету в следующем порядке:

1. **Критические / Blocker / Highest** 🔴
2. **Серьезный / Critical / High** 🟠
3. **Значительный / Major / Medium** 🟡
4. **Незначительный / Minor / Low** 🔵
5. **Остальные / Lowest** ⚪

Внутри каждой группы сортируй по статусу:

- В работе / In Progress / In Dev / In Test / Needs QA / To Review / To Dev
- К выполнению / Open / To Do / New / Backlog

Выведи в формате таблицы Markdown:

```markdown
## 📋 Мои задачи в Jira (N шт.)

### 🔴 Критические

| Ключ           | Приоритет   | Статус | Задача | Проект | Обновлено  |
| -------------- | ----------- | ------ | ------ | ------ | ---------- |
| **`DDS-3876`** | Критический | In Dev | ...    | DDS    | 2026-07-14 |

### 🟡 Средние

| ...
```

Если задач нет — сообщи:

> "Активных задач в Jira не найдено."

### Шаг 4 (опционально): Фильтрация по параметрам

Если пользователь указал дополнительные параметры, модифицируй JQL:

| Параметр пользователя                         | Модификация JQL                                  |
| --------------------------------------------- | ------------------------------------------------ |
| только определённый проект (`project = XYZ`)  | Добавь `AND project = "XYZ"`                     |
| только просроченные                           | Добавь `AND duedate < now() AND duedate != null` |
| без определённого проекта (например `без HR`) | Добавь `AND project != "HR"`                     |
| конкретный тип (`только баги`)                | Добавь `AND issuetype = Bug`                     |
| по статусу (`в работе`)                       | Добавь `AND statusCategory = "In Progress"`      |
| по лейблу (`с меткой ML`)                     | Добавь `AND labels = ML`                         |

### Шаг 5 (опционально): Детальная информация

Если пользователь попросил детали по конкретной задаче, используй `jira_get_issue` с параметром `issue_key=<KEY>` и нужными `fields`, например:

- `description` — описание задачи
- `comment_limit=10` — последние комментарии
- `include=comments,changelog` — раскрыть комментарии и историю
- `include=status_changes,status_summary` — время в каждом статусе

## Особенности

- **Язык**: в выводе сохраняй оригинальные названия на русском (как в Jira)
- **Сортировка по умолчанию**: приоритет DESC, потом updated DESC
- **Лимит**: максимум 50 задач за один запрос; если задач больше — предупреди пользователя и предложи уточнить фильтр
- **Конфиденциальность**: показывай только задачи, где текущий пользователь — assignee

## Примеры вызовов

### Простой запрос

```python
mcp__mcp-atlassian__jira_search(
    jql="assignee = currentUser() AND resolution = Unresolved ORDER BY priority DESC, updated DESC",
    fields="summary,status,priority,issuetype,assignee,reporter,updated,created,duedate,labels,project",
    limit=50
)
```

### Запрос без HR-проекта

```python
mcp__mcp-atlassian__jira_search(
    jql="assignee = currentUser() AND resolution = Unresolved AND project != \"HR\" ORDER BY priority DESC, updated DESC",
    fields="summary,status,priority,issuetype,updated,duedate,labels,project",
    limit=50
)
```

### Детали по задаче

```python
mcp__mcp-atlassian__jira_get_issue(
    issue_key="DDS-3876",
    fields="summary,status,priority,issuetype,description,assignee,reporter,created,updated,duedate,labels",
    include="comments,changelog"
)
```

## Частые ошибки

1. **Не фильтровать закрытые задачи** вручную после JQL — `resolution = Unresolved` работает не везде
2. **Не группировать по приоритету** — пользователю удобнее видеть критическое сверху
3. **Забыть выводить проект** — задачи могут быть из разных проектов (DDS, DSRC, HR, HRDW и т.д.)
4. **Не показать дату обновления** — она помогает понять, что задача "зависла"

## Быстрый ответ

Если пользователь просто спросил "покажи мои задачи" — выполни полный алгоритм и выведи таблицу. Не задавай уточняющих вопросов без необходимости.
