const std = @import("std");
const aoc = @import("./aoc.zig");
const input = @import("./utils/input.zig");
const sol = @import("./solutions/solution.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("memory leak detected");
    }
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const aocArgs = aoc.parse_args(args) catch |err| {
        std.debug.print("Failed to parse args: {}\n", .{err});
        try printHelp(args[0]);
        return;
    };

    try runSolution(allocator, aocArgs.year, aocArgs.day);
}

fn runSolution(allocator: std.mem.Allocator, year: u16, day: u8) !void {
    // Pass the allocator down
    const dayInput = try input.readDayInput(allocator, year, day);
    defer allocator.free(dayInput);

    const solutions = sol.getSolutions();

    if (solutions.get(year, day)) |solution| {
        std.debug.print("\nRunning Year {} Day {} solutions:\n", .{ year, day });
        const first_result = solution.run_first(allocator, dayInput);
        std.debug.print("Part 1:\n{s}\n", .{first_result}); //
        const second_result = solution.run_second(allocator, dayInput);
        std.debug.print("Part 2:\n{s}\n", .{second_result});
    } else {
        std.debug.print("Solution not found for Year {} Day {}\n", .{ year, day });
        try printAvailableSolutions();
    }
}

fn printHelp(binaryPath: []const u8) !void {
    const writer = std.io.getStdOut().writer();
    try writer.print("Usage: {s} <year> <day>\n", .{binaryPath});
    try printAvailableSolutions();
}

fn printAvailableSolutions() !void {
    const Solutions = sol.getSolutions();
    const writer = std.io.getStdOut().writer();

    try writer.print("\nAvailable solutions:\n", .{});
    for (Solutions.getAvailableYears()) |year| {
        try writer.print("Year {}: Days ", .{year});
        for (Solutions.getAvailableDays(year), 0..) |day, i| {
            if (i > 0) try writer.print(", ", .{});
            try writer.print("{}", .{day});
        }
        try writer.print("\n", .{});
    }
}
