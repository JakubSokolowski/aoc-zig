#  cannot format slice without a specifier (i.e. {s} or {any})

## Symptoms

```markdown
/opt/homebrew/bin/zig run --color on /Users/jakub.sokolowski/side/aoc-zig/main.zig -O ReleaseFast -- 2023 1
/opt/homebrew/Cellar/zig/0.13.0/lib/zig/std/fmt.zig:632:21: error: cannot format slice without a specifier (i.e. {s} or {any})
                    @compileError("cannot format slice without a specifier (i.e. {s} or {any})");
                    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
referenced by:
    formatanon_5446: /opt/homebrew/Cellar/zig/0.13.0/lib/zig/std/fmt.zig:185:23
    printanon_4487: /opt/homebrew/Cellar/zig/0.13.0/lib/zig/std/io/Writer.zig:24:26
    remaining reference traces hidden; use '-freference-trace' to see all reference traces
Process finished with exit code 1
```

## Fix
If you get that check your `std.debug.print`, this snippet was causing the issue:

```zig
std.debug.print("\nRunning Year {} Day {} solutions:\n", .{ year, day });
const first_result = solution.run_first(allocator, dayInput);
std.debug.print("Part 1:\n{}", .{first_result});
const second_result = solution.run_second(allocator, dayInput);
std.debug.print("Part 2:\n{}", .{second_result});
```
This error occurs when trying to print a slice without specifying the format. The fix is to use `{s}` specifier for the slice:

```zig