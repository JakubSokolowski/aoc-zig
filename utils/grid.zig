const std = @import("std");
const assert = std.debug.assert;

pub const Dimensions = struct {
    rows: usize,
    cols: usize,
};

const GridError = error{
    InconsistentRowLength,
};

pub const Grid = struct {
    data: []u32,
    rows: usize,
    cols: usize,
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, rows: usize, cols: usize) !Self {
        const data = try allocator.alloc(u32, rows * cols);
        return Self{
            .data = data,
            .rows = rows,
            .cols = cols,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.data);
    }

    fn determineGridDimensions(file_path: []const u8) !Dimensions {
        const file = try std.fs.cwd().openFile(file_path, .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        const reader = buf_reader.reader();

        var rows: usize = 0;
        var cols: usize = 0;
        var buf: [1024]u8 = undefined;

        while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            if (line.len == 0) continue;

            var numbers = std.mem.tokenizeScalar(u8, line, ' ');
            var col_count: usize = 0;
            while (numbers.next()) |_| {
                col_count += 1;
            }

            if (cols == 0) {
                cols = col_count;
            } else if (col_count != cols) {
                return error.InconsistentRowLength;
            }
            rows += 1;
        }

        if (rows == 0 or cols == 0) {
            return error.EmptyGrid;
        }

        return Dimensions{ .rows = rows, .cols = cols };
    }

    pub fn initFromFile(allocator: std.mem.Allocator, file_path: []const u8) !Self {
        const dim = try Self.determineGridDimensions(file_path);

        const file = try std.fs.cwd().openFile(file_path, .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        const reader = buf_reader.reader();

        var grid = try Self.init(allocator, dim.rows, dim.cols);
        var current_row: usize = 0;

        // Second pass: fill the grid
        var buf: [1024]u8 = undefined;
        while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            if (line.len == 0) continue;

            var numbers = std.mem.tokenizeScalar(u8, line, ' ');
            var current_col: usize = 0;

            while (numbers.next()) |num_str| {
                const num = try std.fmt.parseInt(u32, num_str, 10);
                grid.set(current_row, current_col, num);
                current_col += 1;
            }
            current_row += 1;
        }

        return grid;
    }

    fn getIndex(self: Self, row: usize, col: usize) usize {
        return row * self.cols + col;
    }

    // Get value at row, col
    pub fn get(self: Self, row: usize, col: usize) u32 {
        assert(row < self.rows);
        assert(col < self.cols);
        return self.data[self.getIndex(row, col)];
    }

    pub fn set(self: *Self, row: usize, col: usize, value: u32) void {
        if (row >= self.rows or col >= self.cols) return;
        self.data[self.getIndex(row, col)] = value;
    }

    pub const CellIterator = struct {
        grid: *const Grid,
        current_row: usize,
        current_col: usize,

        pub const Cell = struct {
            row: usize,
            col: usize,
            value: u32,
        };

        pub fn next(self: *CellIterator) ?Cell {
            if (self.current_row >= self.grid.rows) return null;

            const cell = Cell{
                .row = self.current_row,
                .col = self.current_col,
                .value = self.grid.data[self.grid.getIndex(self.current_row, self.current_col)],
            };

            // Move to next position
            self.current_col += 1;
            if (self.current_col >= self.grid.cols) {
                self.current_col = 0;
                self.current_row += 1;
            }

            return cell;
        }
    };

    pub fn iterator(self: *const Self) CellIterator {
        return CellIterator{
            .grid = self,
            .current_row = 0,
            .current_col = 0,
        };
    }

    pub fn print(self: Self) void {
        var row: usize = 0;
        while (row < self.rows) : (row += 1) {
            var col: usize = 0;
            while (col < self.cols) : (col += 1) {
                if (col > 0) std.debug.print(" ", .{});
                std.debug.print("{:2}", .{self.get(row, col)});
            }
            std.debug.print("\n", .{});
        }
    }
};

test "Grid" {
    const allocator = std.heap.page_allocator;
    var grid = try Grid.initFromFile(allocator, "data/grid.txt");
    defer grid.deinit();

    grid.print();
}
