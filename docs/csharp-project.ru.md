# C# / .NET проект для dryer

Краткий чеклист: что должно быть в репозитории, чтобы dryer находил **кандидатов на дубли** среди методов C# и писал `.metrics/dry.edn`.

Dryer **не** запускает тесты и **не** читает покрытие — только исходники `.cs` в production-коде. Границы методов совпадают с [crapper](https://github.com/unclebob/crapper) и [mutator](../mutator/docs/csharp-project.ru.md): те же тела, что попадают в CRAP и мутации.

## Структура solution

| Что | Зачем |
|-----|--------|
| Production `.csproj` и `.cs` | Формы для нормализации и попарного сравнения |
| Test-проекты и `*Tests.cs` | **Не** обходятся (как в crapper discover) |
| `bin/`, `obj/`, `.vs/` | **Пропускаются** при обходе (генерация и IDE) |

Тестовый `.csproj` и Coverlet для dryer **не нужны**.

## Что сравнивается

| В отчёте | Не сравнивается |
|----------|-----------------|
| Метод с `{ ... }` или `=>` | Конструкторы, property get/set |
| Только пара `.cs` **одного языка** | Local functions и лямбды как отдельные формы |
| Имена вызовов/методов в отпечатке сохраняются, локали — нет | `*Tests.cs`, `*Test.cs`, каталоги `test`/`tests`/… |
| | `*.Designer.cs`, `*.g.cs`, `*.generated.cs` |

Порог по умолчанию `--threshold 0.82`, минимум `--min-lines 4`, `--min-nodes 20`.

## Чем C# отличается от Java (в dryer)

| Тема | Java | C# |
|------|------|-----|
| Единица | `method_declaration` + `block` | + **`arrow_expression_clause`** |
| Вложенность | не метод во внутреннем/локальном классе | не метод внутри другого метода / lambda / local function |
| Расширение | `.java` | `.cs` |
| Проектные каталоги | `target`, … | те же + **`bin`**, **`obj`**, **`.vs`** |

## Запуск

Из каталога dryer (Windows):

```powershell
cd D:\path\to\dryer
.\.venv\Scripts\python.exe -m dryer --root "D:\path\to\YourSolution"
```

| Флаг | Эффект |
|------|--------|
| `--min-lines 3 --min-nodes 10` | Ослабить отсечку коротких форм |
| `--threshold 0.9` | Меньше кандидатов |
| `--changed` | Только файлы из `git status` |
| `path-or-filter …` | Ограничить каталог или маску |

Нужны **Python**, tree-sitter C# (зависимость пакета), обход readable `.cs`.

## Частые проблемы

1. **Хелперы в test-проекте** без суффикса `Tests` (например `GlpiTestHttp.cs`) могут попасть в отчёт — как у crapper; держите имя `*Tests.cs` или вынесите в production только то, что нужно анализировать.
2. **Дубли в разных слоях** (Application vs Infrastructure) dryer покажет как кандидаты — это ожидаемо, ревью вручную.
3. **Очень большой solution** — сузьте `--source-root` или positional filter (`Application`, один `.csproj`).

## Минимальный smoke-test

```powershell
.\.venv\Scripts\python.exe -m dryer --root path\to\solution --min-lines 1 --min-nodes 1 Application
# stdout: DUPLICATE score=… или «No duplicate candidates»
# .metrics/dry.edn
```

---

[English version](csharp-project.md)
