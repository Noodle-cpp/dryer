# C# / .NET project layout for dryer

Short checklist for **duplicate candidates** and `.metrics/dry.edn`.

Dryer does **not** run tests or read coverage. It walks production `.cs` files and compares normalized method bodies — same boundaries as crapper and mutator.

## Solution layout

- Production `.cs` under your libraries.
- Test projects, `*Tests.cs`, and generated sources are skipped.
- **`bin/`**, **`obj/`**, **`.vs/`** are skipped while walking the tree.

Coverlet and test projects are not required.

## Compared vs skipped

Compared: methods with `{ }` or `=>` bodies. Skipped: constructors, accessors, lambdas/local functions as separate entries, test and generated files.

Default `--threshold 0.82`, `--min-lines 4`, `--min-nodes 20`.

## C# vs Java

C# adds expression-bodied methods and skips `bin` / `obj` / `.vs`. Nested-method rules match the Java idea (no method inside another executable).

## Running dryer

```powershell
cd path\to\dryer
.\.venv\Scripts\python.exe -m dryer --root "D:\path\to\YourSolution"
```

Use `--changed`, `--source-root`, positional filters, and `--min-lines` / `--min-nodes` as needed.

## Smoke test

```powershell
.\.venv\Scripts\python.exe -m dryer --root path\to\solution --min-lines 1 --min-nodes 1 Application
```

---

[Russian version](csharp-project.ru.md)
