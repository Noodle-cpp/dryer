# C# / .NET проект для dryer

Краткий чеклист: что должно быть в репозитории, чтобы dryer находил **кандидатов на дубли** среди методов C# и писал `.metrics/dry.edn`.

Dryer **не** запускает тесты, **не** читает покрытие и **не** нуждается в `dotnet` — только обход `.cs` и сравнение нормализованных тел методов. Границы форм совпадают с [crapper](https://github.com/Noodle-cpp/crapper/blob/main/docs/csharp-project.ru.md) и [mutator](https://github.com/Noodle-cpp/mutator/blob/main/docs/csharp-project.ru.md) (те же unit’ы, что CRAP и мутации).

## Структура solution

| Что | Зачем |
|-----|--------|
| Production `.cs` в библиотеках (Application, Domain, …) | Кандидаты на сравнение |
| Test `.csproj` / `*Tests.cs` | **Не** обходятся |
| `bin/`, `obj/`, `.vs/` | Пропуск каталогов (арtefacts сборки и IDE) |
| `pom.xml` / `dotnet` | **Не требуются** — в отличие от crapper/mutator |

Типовая схема та же, что для crapper, но **Coverlet и зелёные тесты не нужны**.

## Что попадает в `.metrics/dry.edn`

| В сравнении | Исключено |
|-------------|-----------|
| `method_declaration` с **`block`** или **`arrow_expression_clause`** | Конструкторы (`constructor_declaration`) |
| Пары только внутри одного языка (`:language "csharp"`) | Property accessors |
| В отпечатке сохраняются **имена вызываемых методов/типов**, локальные имена и литералы — нет | Local functions, лямбды как отдельные формы |
| | `*Tests.cs`, `*Test.cs`, каталоги `test` / `tests` / … |
| | `*.Designer.cs`, `*.g.cs`, `*.generated.cs` |

Порог по умолчанию **`--threshold 0.82`**, отсечка **`--min-lines 4`**, **`--min-nodes 20`**.

## Чем C# отличается от Java (в dryer)

| Тема | Java | C# |
|------|------|-----|
| Расширение | `.java` | `.cs` |
| Тело формы | только **`block`** | **`block`** или **`=>`** (`arrow_expression_clause`) |
| Абстрактный метод без тела | не кандидат | не кандидат (нет `block` / `=>`) |
| Вложенный метод | не внутри другого `method_declaration` / constructor / lambda | + **`local_function_statement`**, **`anonymous_function_expression`** |
| Local class **внутри метода** | методы inner class **не** кандидаты | то же |
| Методы типов на уровне class/struct | кандидаты, если есть `block` | + expression body |
| Test-файлы по имени | `*Test.java`, каталоги test/… | `*Tests.cs`, `*Test.cs`, те же каталоги |
| Generated | обычно под `target/` (skip) | явные суффиксы `*.Designer.cs`, `*.g.cs`, … |
| Каталоги сборки | `target`, `build`, … | те же + **`bin`**, **`obj`**, **`.vs`** |
| Maven / SDK | не используется dryer | **`dotnet` не нужен** |
| Покрытие / CRAP | — | dryer **не** использует Cobertura/JaCoCo |

Нормализация: как у dry4clj-идеи для JVM — операторы и форма дерева, не имена локальных переменных.

## Запуск

Первый запуск создаёт `.venv` в каталоге dryer (или используйте уже созданный).

```powershell
cd D:\path\to\dryer
python -m venv .venv
.\.venv\Scripts\pip install -e .
.\.venv\Scripts\python.exe -m dryer --root "D:\path\to\YourSolution"
```

| Флаг | Эффект |
|------|--------|
| `--min-lines 3 --min-nodes 10` | Больше коротких форм |
| `--threshold 0.9` | Меньше пар в отчёте |
| `--changed` | Только изменённые по git файлы |
| `--source-root sub\dir` | Обход не всего `--root` |
| `Application` … | Positional filter по пути |

Код выхода **`0`** после отчёта (даже если кандидатов нет), **`1`** — ошибка аргументов.

## Частые проблемы

1. **Хелперы `.cs` в test-проекте** без суффикса `Tests` — могут анализироваться (ограничение discover, как у crapper).
2. **Похожие sync-пайплайны** в разных сервисах дают score 0.82–0.95 — это сигнал к ревью, не баг.
3. **Короткие методы** (1–3 строки) по умолчанию отфильтровываются `--min-lines 4`.

## Минимальный smoke-test

```powershell
.\.venv\Scripts\python.exe -m dryer --root "D:\path\to\YourSolution" --min-lines 1 --min-nodes 1 TP.Cmdb.Glpi.Sync.Application
# DUPLICATE score=… в stdout и/или «No duplicate candidates»
# файл .metrics/dry.edn
```

---

[English version](csharp-project.md)
