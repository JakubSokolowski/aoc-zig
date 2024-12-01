const std = @import("std");

pub const Solution = struct {
    run_first: *const fn (allocator: std.mem.Allocator, []const u8) []const u8,
    run_second: *const fn (allocator: std.mem.Allocator, []const u8) []const u8,
};

pub fn getSolutions() type {
    return struct {
        // Initialize solutions map at compile time
        pub fn get(year: u16, day: u8) ?Solution {
            switch (year) {
                2023 => switch (day) {
                    1 => return Solution{
                        .run_first = @import("./2023/day01.zig").run_first,
                        .run_second = @import("./2023/day01.zig").run_second,
                    },
                    else => return null,
                },
                2024 => switch (day) {
                    1 => return Solution{
                        .run_first = @import("./2024/day01.zig").run_first,
                        .run_second = @import("./2024/day01.zig").run_second,
                    },
                    else => return null,
                },
                else => return null,
            }
        }

        pub fn getAvailableYears() []const u16 {
            return &[_]u16{ 2023, 2024 };
        }

        pub fn getAvailableDays(year: u16) []const u8 {
            return switch (year) {
                2023 => &[_]u8{1},
                2024 => &[_]u8{1},
                else => &[_]u8{},
            };
        }
    };
}
