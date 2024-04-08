const std = @import("std");
const enums = @import("enums.zig");

const Sqr = enums.Sqr;
const Fil = enums.Fil;
const Rnk = enums.Rnk;
const Col = enums.Col;
const Pcs = enums.Pcs;
const ColPcs = enums.ColPcs;

pub const ANSICode = enum(u8) {
    const Self = @This();
    bold_on = 1,
    bold_off = 22,
    all_off = 0,
    fg_off = 39,
    bg_off = 49,
    fg_white = 37,
    fg_black = 30,
    fg_gray = 90,
    fg_magenta = 35,
    fg_cyan = 36,
    bg_white = 47,
    bg_black = 40,
    bg_gray = 100,
    bg_magenta = 45,
    bg_cyan = 46,
    _,

    pub fn toInt(self: Self) u8 {
        return @intFromEnum(self);
    }

    pub fn format(
        self: Self,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("\u{001b}[{d}m", .{self.toInt()});
    }
};

pub const ANSIChar = struct {
    const Self = @This();
    chr: u21,
    pad: u2 = 0,
    pre: []const ANSICode = &[1]ANSICode{.all_off},
    pst: []const ANSICode = &[1]ANSICode{.all_off},

    pub fn format(
        self: Self,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        var str: [4]u8 = undefined;
        const length = std.unicode.utf8Encode(self.chr, &str) catch unreachable;
        for (self.pre) |prefix| try writer.print("{any}", .{prefix});
        try writer.print("{s}", .{str[0..length]});
        for (0..self.pad) |_| try writer.print(" ", .{});
        for (self.pst) |postfix| try writer.print("{any}", .{postfix});
    }
};

pub const PieceSet = enum(u2) {
    const Self = @This();
    const len = 3;
    const arr = [len][12]u21{
        .{ 'X', 'X', 'X', 'X', 'X', 'X', 'x', 'x', 'x', 'x', 'x', 'x' },
        .{ 'P', 'N', 'B', 'R', 'Q', 'K', 'p', 'n', 'b', 'r', 'q', 'k' },
        .{ '\u{2659}', '\u{2658}', '\u{2657}', '\u{2656}', '\u{2655}', '\u{2654}', '\u{265f}', '\u{265e}', '\u{265d}', '\u{265c}', '\u{265b}', '\u{265a}' },
    };
    debug,
    basic,
    fancy,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(@min(n, len - 1));
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn get(self: Self) [12]u21 {
        return arr[self.toInt()];
    }

    pub fn getidx(self: Self, i: u4) u21 {
        return self.get()[@min(i, 11)];
    }
};

pub const ColorSet = enum {
    const Self = @This();
    const len = 3;
    const fgbg_off = [2]ANSICode{ .fg_off, .bg_off };
    pub const Style = struct {
        lsqr_pre: []const ANSICode,
        lsqr_pst: []const ANSICode,
        dsqr_pre: []const ANSICode,
        dsqr_pst: []const ANSICode,
    };
    const styles = [len]Style{
        Style{
            .lsqr_pre = &[1]ANSICode{.all_off},
            .lsqr_pst = &[1]ANSICode{.all_off},
            .dsqr_pre = &[1]ANSICode{.all_off},
            .dsqr_pst = &[1]ANSICode{.all_off},
        },
        Style{
            .lsqr_pre = &[2]ANSICode{ .bg_white, .fg_black },
            .lsqr_pst = &fgbg_off,
            .dsqr_pre = &[2]ANSICode{ .bg_black, .fg_white },
            .dsqr_pst = &fgbg_off,
        },
        Style{
            .lsqr_pre = &[2]ANSICode{ .bg_cyan, .fg_white },
            .lsqr_pst = &fgbg_off,
            .dsqr_pre = &[2]ANSICode{ .bg_magenta, .fg_white },
            .dsqr_pst = &fgbg_off,
        },
    };
    none,
    bw,
    retro,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(@min(n, len - 1));
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn get(self: Self) Style {
        return styles[self.toInt()];
    }
};

pub const Boards = enum(u4) {
    const Self = @This();
    const len = 6;
    pub const Style = struct {
        pcs: PieceSet = .basic,
        col: ColorSet = .none,
        pad: u2 = 1,
        alt_pcs: bool = false,
        cum_empty: bool = false,
        empty: u21 = ' ',
        newline: []const u8 = "\n",
        final: []const u8 = "\n",

        pub fn get(self: Style, colpcs: ColPcs, sqr: Sqr) ANSIChar {
            var islight = sqr.toCol() == .white;
            var col = self.col.get();
            var curpcs = if (!islight and self.alt_pcs) colpcs.opp() else colpcs;
            var chr = if (curpcs == .none) self.empty else self.pcs.getidx(curpcs.toInt());
            var pre: []const ANSICode = if (islight) col.lsqr_pre else col.dsqr_pre;
            var pst: []const ANSICode = if (islight) col.lsqr_pst else col.dsqr_pst;
            return ANSIChar{ .chr = chr, .pre = pre, .pst = pst, .pad = self.pad };
        }
    };
    pub const styles = [len]Style{
        Style{ .pcs = .debug, .empty = '\u{00b7}', .final = "\n\n" },
        Style{ .empty = '\u{00b7}' },
        Style{ .cum_empty = true, .newline = "/", .final = "", .pad = 0 },
        Style{ .col = .retro, .empty = '\u{00b7}' },
        Style{ .pcs = .fancy, .col = .bw, .alt_pcs = true },
        Style{ .pcs = .fancy, .col = .retro, .alt_pcs = true },
    };
    debug,
    basic,
    fen,
    retrobasic,
    fancy,
    retrofancy,

    pub fn toInt(self: Self) u4 {
        return @intFromEnum(self);
    }

    pub fn style(self: Self) Style {
        return styles[self.toInt()];
    }
};

pub fn main() !void {
    // Example usage
    // const stdout = std.io.getStdOut().writer();
    std.debug.print("{d}\n", .{Boards.retrofancy.style().get(.R, .a1)});
}
