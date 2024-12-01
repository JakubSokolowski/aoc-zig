const std = @import("std");

const ArgsError = error{ MissingYear, InvalidYear, MissingDay, InvalidDay };

pub fn parse_args(args: [][]u8) ArgsError!AocArgs {
    switch (args.len) {
        1 => return ArgsError.MissingYear,
        2 => return ArgsError.MissingDay,
        else => {
            const year = args[1];
            const parsed_year = std.fmt.parseInt(u16, year, 10) catch |err| {
                std.debug.print("Failed to parse year: {}\n", .{err});
                return ArgsError.InvalidYear;
            };

            if (parsed_year < 2015 or parsed_year > 2025) {
                return ArgsError.InvalidYear;
            }

            const day = args[2];
            const parsed_day = std.fmt.parseInt(u8, day, 10) catch {
                return ArgsError.InvalidDay;
            };

            if (parsed_day < 1 or parsed_day > 25) {
                return ArgsError.InvalidDay;
            }

            return AocArgs{ .year = parsed_year, .day = parsed_day };
        },
    }
}

pub const AocArgs = struct {
    day: u8,
    year: u16,

    pub fn format(self: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("AocArgs{{ .day = {}, .year = {} }}", .{ self.day, self.year });
    }
};
