const std = @import("std");
const parsing = @import("../../utils/parsing.zig");
const Lines = @import("../../utils/parsing.zig").Lines;

pub fn run_first(allocator: std.mem.Allocator, input: []const u8) []const u8 {
    var lines = Lines.init(allocator, input) catch |err| {
        std.debug.print("Failed to parse lines: {}\n", .{err});
        return "";
    };
    defer lines.deinit();

    var sum: u32 = 0;

    for (lines.items()) |line| {
        const result = getFirstLastDigit(line) catch {
            return "";
        };
        const number = result.first * 10 + result.last;
        sum += number;
    }

    std.debug.print("Sum: {}\n", .{sum});
    return std.fmt.allocPrint(allocator, "{d}", .{sum}) catch |err| {
        std.debug.print("Failed to format sum: {}\n", .{err});
        return "";
    };
}

fn getFirstLastDigit(line: []const u8) !struct { first: u8, last: u8 } {
    var first: ?u8 = null;
    var last: ?u8 = null;

    for (line) |char| {
        if (std.ascii.isDigit(char)) {
            const digit = char - '0';
            if (first == null) first = digit;
            last = digit;
        }
    }

    if (first == null or last == null) {
        return error.NoDigitsFound;
    }

    return .{ .first = first.?, .last = last.? };
}

test "getFirstLastDigit" {
    const result1 = try getFirstLastDigit("abc1def2ghi3");
    try std.testing.expectEqual(result1.first, 1);
    try std.testing.expectEqual(result1.last, 3);

    const result2 = try getFirstLastDigit("1abc");
    try std.testing.expectEqual(result2.first, 1);
    try std.testing.expectEqual(result2.last, 1);

    const result3 = try getFirstLastDigit("abc2");
    try std.testing.expectEqual(result3.first, 2);
    try std.testing.expectEqual(result3.last, 2);

    try std.testing.expectError(error.NoDigitsFound, getFirstLastDigit("abcdef"));
}

pub fn run_second(_: std.mem.Allocator, input: []const u8) []const u8 {
    std.debug.print("Input: {s}\n", .{input});
    return "";
}
