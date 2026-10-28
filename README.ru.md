# dryer

[English documentation](README.md)

dryer находит кандидатов на дублирование кода в Clojure, Java, C#, Go, TypeScript, Rust и Python. Один запуск определяет язык каждого исходного файла, нормализует формы этого языка и сообщает пары, чья структура достаточно близка для ревью.

Clojure следует [dry4clj](https://github.com/unclebob/dry4clj). Остальные языки используют ту же идею для функций и методов, которые [crapper](https://github.com/unclebob/crapper) и [mutator](https://github.com/unclebob/mutator) уже считают одной единицей. Форма сравнивается только с формами на том же языке.

Оценка — коэффициент Жаккара структурных отпечатков:

```text
score = общие отпечатки / все отпечатки, встреченные в любой из форм
```

`1.0` означает одинаковое множество отпечатков нормализованных структур. Порог по умолчанию `--threshold 0.82` отбирает кандидатов, достойных просмотра.

Эти две функции дают `1.0`. Имена, локали, предикаты и функции в `map` различаются — incidental-символы нормализуются. При запуске по умолчанию они всё равно пропускаются: три строки, минимум по умолчанию — четыре.

```clojure
(defn alpha [xs]
  (let [ys (filter odd? xs)]
    (map inc ys)))

(defn beta [items]
  (let [kept (filter even? items)]
    (map dec kept)))
```

Та же форма на других языках тоже `1.0`: имя вызываемой функции или метода сохраняется, локали — нет.

```java
int alpha(int[] xs) {
  int[] ys = filter(xs, odd);
  return map(ys, inc);
}
```

```python
def beta(items):
    kept = filter(items, even)
    return map(kept, dec)
```

Остаются имя вызова или метода, оператор и форма дерева. Уходят имя локали, поля, литералы, ключевые слова. В Clojure `(:kind m)` и `(:id row)` — одна форма. Так же `order.total` и `row.amount`.

## Запуск

```bash
./dryer
```

При первом запуске создаётся `.venv` и устанавливается инструмент. Из корня проекта обходится дерево, пропускаются `test`, `spec`, `vendor`, `node_modules` и `target`, записываются два результата:

- отчёт в stdout, сначала ближайшие совпадения
- `.metrics/dry.edn`, перезаписывается при каждом успешном анализе

```bash
./dryer src/demo src/ui          # эти файлы и деревья
./dryer --changed                # добавления и правки по git
./dryer billing                  # фрагмент пути
./dryer --threshold 0.9 src
./dryer --edn --min-lines 3 src
```

```text
--threshold N    Минимальная структурная схожесть, по умолчанию 0.82
--min-lines N    Минимум строк исходника в кандидате, по умолчанию 4
--min-nodes N    Минимум нормализованных синтаксических узлов, по умолчанию 20
--format F       text или edn, по умолчанию text
--edn            То же, что --format edn
--text           То же, что --format text
```

Нормализованные синтаксические узлы — структурные части после замены incidental-имён и литералов. `--min-nodes` отбрасывает формы меньше этого порога до сравнения.

Текстовый вывод по умолчанию для invoice и receipt из dry4clj. Отличие — одна лишняя привязка:

```text
DUPLICATE score=0.89
  src/billing/invoice.clj:3-13
  src/billing/receipt.clj:3-14
```

`.metrics/dry.edn` — тот же отчёт, что dry4clj печатает как EDN, с добавленным языком:

```clojure
{:candidates
 [{:score 0.890909090909
   :language "clojure"
   :left {:file "src/billing/invoice.clj", :start-line 3, :end-line 13}
   :right {:file "src/billing/receipt.clj", :start-line 3, :end-line 14}
   :left-nodes 158
   :right-nodes 166}]}
```

## Что сравнивает каждый язык

| Язык | Кандидат | Исключено |
| --- | --- | --- |
| Clojure | каждая форма верхнего уровня, кроме `ns` | ветки reader-conditional кроме `:clj` |
| Java | методы с телом | конструкторы, абстрактные методы, методы во внутренних/локальных классах |
| C# | методы с телом или expression body | конструкторы, accessors, методы в lambda и local functions |
| Go | функции и методы с телом | литералы функций остаются во внешней функции |
| TypeScript | функции, методы, стрелочные функции верхнего уровня | колбэки, вложенные во внешнюю функцию |
| Rust | функции и методы с телом | функции в `mod tests`, замыкания |
| Python | функции и методы | функции, вложенные во внешнюю |

Reader-conditional в Clojure сохраняет ветку `:clj`, как dry4clj. Syntax-quote остаётся формой `syntax-quote`, без развёртки.

Отсутствующая или нечитаемая форма Clojure сообщается в stderr. Уже прочитанные формы всё равно сравниваются. Код выхода `0` после отчёта, `1` при ошибке использования, `2` при неизвестном `--format`.

## Разработка

```bash
python3 -m venv .venv
.venv/bin/pip install -e '.[dev]'
.venv/bin/pytest
```
