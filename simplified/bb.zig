const std = @import("std");
const cnst = @import("cnst.zig");

const Sqr = cnst.Sqr;
const Fil = cnst.Fil;
const Rnk = cnst.Rnk;
const Col = cnst.Col;
const Pcs = cnst.Pcs;
const ColPcs = cnst.ColPcs;

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

pub const BB = packed struct {
    const Self = @This();
    pub const len = 1;
    pub const is64 = true;
    const Serializer = struct {
        const S = @This();
        bits: u64,
        pub fn next(s: *S) ?Sqr {
            var pos = @ctz(s.bits);
            if (pos == 64) return null;
            s.bits &= ~(@as(u64, 1) << @truncate(pos));
            return Sqr.frInt(@truncate(pos));
        }
    };
    a1: bool = false,
    b1: bool = false,
    c1: bool = false,
    d1: bool = false,
    e1: bool = false,
    f1: bool = false,
    g1: bool = false,
    h1: bool = false,
    a2: bool = false,
    b2: bool = false,
    c2: bool = false,
    d2: bool = false,
    e2: bool = false,
    f2: bool = false,
    g2: bool = false,
    h2: bool = false,
    a3: bool = false,
    b3: bool = false,
    c3: bool = false,
    d3: bool = false,
    e3: bool = false,
    f3: bool = false,
    g3: bool = false,
    h3: bool = false,
    a4: bool = false,
    b4: bool = false,
    c4: bool = false,
    d4: bool = false,
    e4: bool = false,
    f4: bool = false,
    g4: bool = false,
    h4: bool = false,
    a5: bool = false,
    b5: bool = false,
    c5: bool = false,
    d5: bool = false,
    e5: bool = false,
    f5: bool = false,
    g5: bool = false,
    h5: bool = false,
    a6: bool = false,
    b6: bool = false,
    c6: bool = false,
    d6: bool = false,
    e6: bool = false,
    f6: bool = false,
    g6: bool = false,
    h6: bool = false,
    a7: bool = false,
    b7: bool = false,
    c7: bool = false,
    d7: bool = false,
    e7: bool = false,
    f7: bool = false,
    g7: bool = false,
    h7: bool = false,
    a8: bool = false,
    b8: bool = false,
    c8: bool = false,
    d8: bool = false,
    e8: bool = false,
    f8: bool = false,
    g8: bool = false,
    h8: bool = false,

    pub fn fr64(board: u64) Self {
        return @bitCast(board);
    }

    pub fn to64(self: Self) u64 {
        return @bitCast(self);
    }

    pub fn chkSqr(self: Self, sqr: Sqr) bool {
        return self.to64() & sqr.to64() > 0;
    }

    pub fn fr(comptime T: type, t: T) Self {
        return switch (@typeInfo(T)) {
            .Vector, .Array => |info| if (info.len == 1 and info.child == u64) @bitCast(t) else comptime {
                @compileError(std.fmt.comptimePrint("Unsupported type: {any}", .{T}));
            },
            .Int, .ComptimeInt => fr64(@truncate(t)),
            .Struct, .Enum, .Union, .Opaque => if (comptime std.meta.trait.hasFn("to64")(T)) fr64(t.to64()),
            else => comptime {
                @compileError(std.fmt.comptimePrint("Unsupported type: {any}", .{T}));
            },
        };
    }

    pub fn format(
        self: Self,
        comptime fmt: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        var brd: Boards = comptime blk: {
            var itr = std.mem.tokenize(u8, fmt, "|");
            while (itr.next()) |opt| {
                if (@hasField(Boards, opt)) {
                    break :blk @field(Boards, opt);
                }
            }
            break :blk .debug;
        };
        var colpcs: ColPcs = comptime blk: {
            var itr = std.mem.tokenize(u8, fmt, "|");
            while (itr.next()) |opt| {
                if (@hasField(ColPcs, opt)) {
                    break :blk @field(ColPcs, opt);
                }
            }
            break :blk .P;
        };
        var style = brd.style();
        var acc: u4 = 0;
        for (0..64) |i| {
            const rnk: u6 = @truncate(7 - (i / 8));
            const fil: u6 = @truncate(i % 8);
            const sqr = Sqr.frInt(rnk * 8 + fil);
            const pcs: ColPcs = if (self.chkSqr(sqr)) colpcs else .none;
            const newline = (fil == 0 and i != 0);
            if (style.cum_empty) {
                if (newline) {
                    if (acc > 0) {
                        try writer.print("{d}", .{acc});
                        acc = 0;
                    }
                    try writer.print("{s}", .{style.newline});
                }
                if (pcs == .none) {
                    acc += 1;
                } else {
                    if (acc > 0) {
                        try writer.print("{d}", .{acc});
                        acc = 0;
                    }
                    try writer.print("{any}", .{style.get(pcs, sqr)});
                }
            } else {
                if (fil == 0 and i != 0) try writer.print("{s}", .{style.newline});
                try writer.print("{any}", .{style.get(pcs, sqr)});
            }
        }
        if (acc > 0) try writer.print("{d}", .{acc});
        try writer.print("{s}", .{style.final});
    }
};

pub fn main() void {
    var bb = BB.fr64(0x44678123);
    std.debug.print("{any}\n", .{bb});
    // comptime var vec: @Vector(2, u64) = [2]u64{ 0x4433, 0x1 };
    std.debug.print("{any}\n", .{@typeInfo(@Vector(2, u64))});
}
