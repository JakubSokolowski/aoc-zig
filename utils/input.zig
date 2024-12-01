const std = @import("std");
const testing = std.testing;

/// Reads the contents of the input file for the given year and day into a buffer
/// Caller owns the returned buffer
pub fn readDayInput(allocator: std.mem.Allocator, year: u16, day: u8) ![]u8 {
    const path = try getInputPath(allocator, year, day);
    defer allocator.free(path);
    return readToString(allocator, path);
}

/// Reads the contents of the file at the given path into a buffer
/// Caller owns the returned buffer
pub fn readToString(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const file_size = try file.getEndPos();
    try file.seekTo(0);
    const buffer = try allocator.alloc(u8, file_size);
    _ = try file.readAll(buffer);
    return buffer;
}

/// Returns the path to the input file for the given year and day
/// Caller owns the returned buffer
pub fn getInputPath(allocator: std.mem.Allocator, year: u16, day: u8) ![]u8 {
    return try std.fmt.allocPrint(allocator, "data/{}/day{:0>2}.txt", .{ year, day });
}

test "getInputPath returns proper path for days before 10" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("memory leak baby!");
    }
    const allocator = gpa.allocator();

    const expected = "data/2023/day01.txt";
    const actual = try getInputPath(allocator, 2023, 1);
    defer allocator.free(actual);
    try testing.expectEqualStrings(expected, actual);
}

test "getInputPath returns proper path for days after 10" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("memory leak");
    }
    const allocator = gpa.allocator();

    const expected = "data/2023/day12.txt";
    const actual = try getInputPath(allocator, 2023, 12);
    defer allocator.free(actual);
    try testing.expectEqualStrings(expected, actual);
}

test "readToString reads the file into a buffer" {
    // Create a temporary test file
    const test_path = "test_data.txt";
    const test_content = "Hello, World!";

    {
        const file = try std.fs.cwd().createFile(test_path, .{});
        defer file.close();
        try file.writeAll(test_content);
    }
    defer std.fs.cwd().deleteFile(test_path) catch {};

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("memory leak");
    }
    const allocator = gpa.allocator();

    const result = try readToString(allocator, test_path);
    defer allocator.free(result);

    try testing.expectEqualStrings(test_content, result);
}
