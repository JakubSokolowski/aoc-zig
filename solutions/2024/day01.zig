const std = @import("std");

pub fn run_first(alloc: std.mem.Allocator, input: []const u8) []const u8 {
    const first_res = total_distance(alloc, input) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return "";
    };
    return first_res;
}

pub fn run_second(alloc: std.mem.Allocator, input: []const u8) []const u8 {
    const second_res = similarity_score(alloc, input) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return "";
    };
    return second_res;
}

pub fn total_distance(alloc: std.mem.Allocator, input: []const u8) ![]const u8 {
    var iter = std.mem.tokenizeAny(u8, input, " \n");

    var left = std.ArrayList(u64).init(alloc);
    defer left.deinit();
    var right = std.ArrayList(u64).init(alloc);
    defer right.deinit();

    var idx: u64 = 0;
    while (iter.next()) |token| {
        const number = try std.fmt.parseInt(u64, token, 10);
        if (idx % 2 == 0) {
            try left.append(number);
        } else {
            try right.append(number);
        }
        idx += 1;
    }

    const cmp = std.sort.asc(u64);
    std.mem.sortUnstable(u64, left.items, {}, cmp);
    std.mem.sortUnstable(u64, right.items, {}, cmp);

    var sum: u64 = 0;

    for (left.items, right.items) |l, r| {
        sum += @max(l, r) - @min(l, r);
    }

    return try std.fmt.allocPrint(alloc, "{d}", .{sum});
}

pub fn similarity_score(alloc: std.mem.Allocator, input: []const u8) ![]const u8 {
    var iter = std.mem.tokenizeAny(u8, input, " \n");

    var left = std.ArrayList(u64).init(alloc);
    defer left.deinit();
    var right = std.ArrayList(u64).init(alloc);
    defer right.deinit();

    var idx: u64 = 0;
    while (iter.next()) |token| {
        const number = try std.fmt.parseInt(u64, token, 10);
        if (idx % 2 == 0) {
            try left.append(number);
        } else {
            try right.append(number);
        }
        idx += 1;
    }

    const cmp = std.sort.asc(u64);
    std.mem.sortUnstable(u64, left.items, {}, cmp);
    std.mem.sortUnstable(u64, right.items, {}, cmp);

    var counter = std.AutoHashMap(u64, u64).init(alloc);
    defer counter.deinit();

    for (right.items) |r| {
        try counter.put(r, if (counter.get(r)) |val| val + 1 else 1);
    }

    var score: u64 = 0;

    for (left.items) |l| {
        score += l * (if (counter.get(l)) |val| val else 0);
    }

    return try std.fmt.allocPrint(alloc, "{d}", .{score});
}

test "total_distance" {
    const allocator = std.testing.allocator;

    const input =
        \\ 3   4
        \\ 4   3
        \\ 2   5
        \\ 1   3
        \\ 3   9
        \\ 3   3
    ;

    const result = try total_distance(allocator, input);
    defer allocator.free(result);
    try std.testing.expectEqualStrings(result, "11");
}

test "similarity_score" {
    const allocator = std.testing.allocator;

    const input =
        \\ 3   4
        \\ 4   3
        \\ 2   5
        \\ 1   3
        \\ 3   9
        \\ 3   3
    ;

    const result = try similarity_score(allocator, input);
    defer allocator.free(result);
    try std.testing.expectEqualStrings(result, "31");
}
