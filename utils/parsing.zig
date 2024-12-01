const std = @import("std");

/// Splits a byte slice into non-empty lines
/// Caller owns returned ArrayList
pub fn splitLines(allocator: std.mem.Allocator, content: []const u8) !std.ArrayList([]const u8) {
    var lines = std.ArrayList([]const u8).init(allocator);
    errdefer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit();
    }

    var iter = std.mem.split(u8, content, "\n");
    while (iter.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &[_]u8{ ' ', '\t', '\r' });
        if (trimmed.len == 0) continue;

        const dup = try allocator.dupe(u8, trimmed);
        try lines.append(dup);
    }

    return lines;
}

pub const Lines = struct {
    lines: std.ArrayList([]const u8),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, content: []const u8) !Lines {
        return .{
            .lines = try splitLines(allocator, content),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Lines) void {
        for (self.lines.items) |line| {
            self.allocator.free(line);
        }
        self.lines.deinit();
    }

    pub fn items(self: Lines) []const []const u8 {
        return self.lines.items;
    }
};

test "splitLines basic functionality" {
    const allocator = std.testing.allocator;

    const input =
        \\first line
        \\  second line
        \\
        \\third line
        \\
        \\
    ;

    var lines = try splitLines(allocator, input);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit();
    }

    try std.testing.expectEqual(@as(usize, 3), lines.items.len);
    try std.testing.expectEqualStrings("first line", lines.items[0]);
    try std.testing.expectEqualStrings("second line", lines.items[1]);
    try std.testing.expectEqualStrings("third line", lines.items[2]);
}
