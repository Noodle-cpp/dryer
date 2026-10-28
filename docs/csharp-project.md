# C# / .NET project layout for dryer

Short checklist for **duplicate candidates** and `.metrics/dry.edn`.

Dryer does not run tests, read coverage, or require **`dotnet`**. It walks production `.cs` files and compares normalized method bodies — same boundaries as [crapper](https://github.com/Noodle-cpp/crapper/blob/main/docs/csharp-project.md) and [mutator](https://github.com/Noodle-cpp/mutator/blob/main/docs/csharp-project.md).

## Solution layout

- Production `.cs` in library projects.
- Skipped: test projects, `*Tests.cs`, generated sources, **`bin/`**, **`obj/`**, **`.vs/`**.
- No Coverlet, Maven, or passing tests required.

## Snapshot rules

Compared: methods with `{ }` or `=>` bodies. Skipped: constructors, accessors, lambdas/local functions as separate entries, test/generated files.

Defaults: `--threshold 0.82`, `--min-lines 4`, `--min-nodes 20`.

## C# vs Java

| Topic | Java | C# |
|-------|------|-----|
| Body | `block` only | `block` or **`=>`** |
| Nested executable | skip inside method/constructor/lambda | also **local function** / **anonymous function** |
| Method in local class inside another method | not a candidate | same |
| Type-level methods | need `block` | need `block` or **`=>`** |
| Test names | `*Test.java` | `*Tests.cs`, `*Test.cs` |
| Build dirs | `target`, … | + **`bin`**, **`obj`**, **`.vs`** |
| Toolchain | unused by dryer | **`dotnet` not needed** |

## Running

```powershell
cd path\to\dryer
.\.venv\Scripts\pip install -e .
.\.venv\Scripts\python.exe -m dryer --root "D:\path\to\YourSolution"
```

Flags: `--changed`, `--source-root`, positional filters, `--min-lines`, `--min-nodes`, `--threshold`.

## Smoke test

```powershell
.\.venv\Scripts\python.exe -m dryer --root path\to\solution --min-lines 1 --min-nodes 1 Application
```

---

[Russian version](csharp-project.ru.md)
