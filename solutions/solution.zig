const std = @import("std");

// Generic solution interface that all day solutions must implement
pub const Solution = struct {
    run_first: *const fn (allocator: std.mem.Allocator, []const u8) []const u8,
    run_second: *const fn (allocator: std.mem.Allocator, []const u8) []const u8,
};

// Comptime function to get all solutions
pub fn getSolutions() type {
    // This will be filled with year/day combinations
    return struct {
        // Initialize solutions map at compile time
        pub fn get(year: u16, day: u8) ?Solution {
            // Add solutions here using comptime branch
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

        // Get available years at compile time
        pub fn getAvailableYears() []const u16 {
            return &[_]u16{ 2023, 2024 };
        }

        // Get available days for a specific year at compile time
        pub fn getAvailableDays(year: u16) []const u8 {
            return switch (year) {
                2023 => &[_]u8{1},
                2024 => &[_]u8{1},
                else => &[_]u8{},
            };
        }
    };
}
