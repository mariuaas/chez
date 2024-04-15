const std = @import("std");

pub const Col = enum(u2) {
    const Self = @This();
    pub const len = 3;
    white,
    black,
    none,
    _,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(@min(n, len - 1));
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn opp(self: Self) Col {
        return switch (self) {
            .white => .black,
            .black => .white,
            else => .none,
        };
    }
};

pub const Pcs = enum(u3) {
    const Self = @This();
    pub const len = 7;
    p,
    n,
    b,
    r,
    q,
    k,
    none,
    _,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(@min(n, len - 1));
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn toColPcs(self: Pcs, player: Col) ColPcs {
        if (self == .none) return .none;
        return switch (player) {
            .white => ColPcs.frInt(self.toInt()),
            .black => ColPcs.frInt(@as(u4, self.toInt()) + 6),
            else => .none,
        };
    }
};

pub const ColPcs = enum(u4) {
    const Self = @This();
    pub const len = 13;
    P,
    N,
    B,
    R,
    Q,
    K,
    p,
    n,
    b,
    r,
    q,
    k,
    none,
    _,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(@min(n, len - 1));
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn toPcs(self: ColPcs) Pcs {
        if (self == .none) return .none;
        return Pcs.frInt(@truncate(self.toInt() % 6));
    }

    pub fn toCol(self: ColPcs) Col {
        if (self == .none) return .none;
        return Col.frInt(@truncate(self.toInt() / 6));
    }

    pub fn opp(self: ColPcs) ColPcs {
        if (self == .none) return .none;
        return self.toPcs().toColPcs(self.toCol().opp());
    }
};

pub const Rnk = enum(u3) {
    const Self = @This();
    const First: u64 = 0xff;
    pub const len = 8;
    pub const Indexer = std.enums.EnumIndexer(Self);
    pub const arr: [len]u64 = blk: {
        var a: [Self.len]u64 = undefined;
        for (0..len) |i| {
            a[i] = Self.frInt(i).init64();
        }
        break :blk a;
    };
    const zro: [len]u64 = blk: {
        var z: [Self.len]u64 = undefined;
        @memset(&z, 0);
        break :blk z;
    };
    _1,
    _2,
    _3,
    _4,
    _5,
    _6,
    _7,
    _8,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(n);
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn cap(self: Self, file: Fil) Sqr {
        return Sqr.frInt(@as(u6, self.toInt()) * 8 + @as(u6, file.toInt()));
    }

    pub fn init64(self: Self) u64 {
        return First << 8 * @as(u6, self.toInt());
    }

    pub fn to64(self: Self) u64 {
        return arr[self.toInt()];
    }

    pub fn cup(enm: []Self) u64 {
        var pred: [len]bool = undefined;
        for (enm) |i| pred[i.toInt()] = true;
        return @reduce(std.builtin.ReduceOp.Or, @select(u64, pred, arr, zro));
    }
};

pub const Fil = enum(u3) {
    const Self = @This();
    const First: u64 = 0x0101010101010101;
    pub const len = 8;
    pub const arr: [len]u64 = blk: {
        var a: [Self.len]u64 = undefined;
        for (0..len) |i| {
            a[i] = Self.frInt(i).init64();
        }
        break :blk a;
    };
    const zro: [len]u64 = blk: {
        var z: [Self.len]u64 = undefined;
        @memset(&z, 0);
        break :blk z;
    };
    pub const Indexer = std.enums.EnumIndexer(Self);
    a,
    b,
    c,
    d,
    e,
    f,
    g,
    h,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(n);
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn cap(self: Self, rank: Rnk) Sqr {
        return rank.cap(self);
    }

    pub fn init64(self: Self) u64 {
        return First << self.toInt();
    }

    pub fn to64(self: Self) u64 {
        return arr[self.toInt()];
    }

    pub fn cup(enm: []Self) u64 {
        var pred: [len]bool = undefined;
        for (enm) |i| pred[i.toInt()] = true;
        return @reduce(std.builtin.ReduceOp.Or, @select(u64, pred, arr, zro));
    }
};

pub const PDia = enum(u4) {
    const Self = @This();
    const First: u64 = 0x8040201008040201;
    pub const len = 15;
    pub const arr: [len]u64 = blk: {
        var a: [Self.len]u64 = undefined;
        for (0..len) |i| {
            a[i] = Self.frInt(i).init64();
        }
        break :blk a;
    };
    const zro: [len]u64 = blk: {
        var z: [Self.len]u64 = undefined;
        @memset(&z, 0);
        break :blk z;
    };
    pub const Indexer = std.enums.EnumIndexer(Self);
    a8,
    a7b8,
    a6c8,
    a5d8,
    a4e8,
    a3f8,
    a2g8,
    a1h8,
    b1h7,
    c1h6,
    d1h5,
    e1h4,
    f1h3,
    g1h2,
    h1,
    _,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(@min(n, len - 1));
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn init64(self: Self) u64 {
        var i: usize = self.toInt();
        return if (i < 8) First << (56 - 8 * i) else First >> (8 * i - 56);
    }

    pub fn to64(self: Self) u64 {
        return arr[self.toInt()];
    }

    pub fn cup(enm: []Self) u64 {
        var pred: [len]bool = undefined;
        for (enm) |i| pred[i.toInt()] = true;
        return @reduce(std.builtin.ReduceOp.Or, @select(u64, pred, arr, zro));
    }
};

pub const NDia = enum(u4) {
    const Self = @This();
    const First: u64 = 0x0102040810204080;
    pub const len = 15;
    pub const arr: [len]u64 = blk: {
        var a: [Self.len]u64 = undefined;
        for (0..len) |i| {
            a[i] = Self.frInt(i).init64();
        }
        break :blk a;
    };
    const zro: [len]u64 = blk: {
        var z: [Self.len]u64 = undefined;
        @memset(&z, 0);
        break :blk z;
    };
    pub const Indexer = std.enums.EnumIndexer(Self);
    a1,
    a2b1,
    a3c1,
    a4d1,
    a5e1,
    a6f1,
    a7g1,
    a8h1,
    b8h2,
    c8h3,
    d8h4,
    e8h5,
    f8h6,
    g8h7,
    h8,
    _,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(n);
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn init64(self: Self) u64 {
        var i: usize = 14 - self.toInt();
        return if (i < 8) First << (56 - 8 * i) else First >> (8 * i - 56);
    }

    pub fn to64(self: Self) u64 {
        return arr[self.toInt()];
    }

    pub fn cup(enm: []Self) u64 {
        var pred: [len]bool = undefined;
        for (enm) |i| pred[i.toInt()] = true;
        return @reduce(std.builtin.ReduceOp.Or, @select(u64, pred, arr, zro));
    }
};

pub const CumLR = enum(u4) {
    const Self = @This();
    const First: u64 = 0x0101010101010101;
    pub const len = 9;
    pub const arr: [len]u64 = blk: {
        var a: [Self.len]u64 = undefined;
        for (0..len) |i| {
            a[i] = Self.frInt(i).init64();
        }
        break :blk a;
    };
    const zro: [len]u64 = blk: {
        var z: [Self.len]u64 = undefined;
        @memset(&z, 0);
        break :blk z;
    };
    cum_z,
    cum_a,
    cum_b,
    cum_c,
    cum_d,
    cum_e,
    cum_f,
    cum_g,
    cum_h,
    _,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(@min(n, len - 1));
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn inv(self: Self) CumRL {
        return CumRL.frInt(@max(0, 8 - self.toInt()));
    }

    pub fn init64(self: Self) u64 {
        var i: usize = self.toInt();
        if (i == 0) return 0;
        if (i >= len) return 0xffffffffffffffff;
        var cur = First;
        for (1..i) |j| cur |= First << j;
        return cur;
    }

    pub fn to64(self: Self) u64 {
        return arr[self.toInt()];
    }

    pub fn cup(enm: []Self) u64 {
        var pred: [len]bool = undefined;
        for (enm) |i| pred[i.toInt()] = true;
        return @reduce(std.builtin.ReduceOp.Or, @select(u64, pred, arr, zro));
    }
};

pub const CumRL = enum(u4) {
    const Self = @This();
    const First: u64 = 0x0101010101010101;
    pub const len = 9;
    pub const arr: [len]u64 = blk: {
        var a: [Self.len]u64 = undefined;
        for (0..len) |i| {
            a[i] = Self.frInt(i).init64();
        }
        break :blk a;
    };
    const zro: [len]u64 = blk: {
        var z: [Self.len]u64 = undefined;
        @memset(&z, 0);
        break :blk z;
    };
    icum_z,
    icum_a,
    icum_b,
    icum_c,
    icum_d,
    icum_e,
    icum_f,
    icum_g,
    icum_h,
    _,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(@min(n, len - 1));
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn inv(self: Self) CumLR {
        return CumLR.frInt(@max(0, 8 - self.toInt()));
    }

    pub fn init64(self: Self) u64 {
        return ~self.inv().to64();
    }

    pub fn to64(self: Self) u64 {
        return arr[self.toInt()];
    }

    pub fn cup(enm: []Self) u64 {
        var pred: [len]bool = undefined;
        for (enm) |i| pred[i.toInt()] = true;
        return @reduce(std.builtin.ReduceOp.Or, @select(u64, pred, arr, zro));
    }
};

pub const CumDU = enum(u4) {
    const Self = @This();
    const First: u64 = 0xff;
    pub const len = 9;
    pub const arr: [len]u64 = blk: {
        var a: [Self.len]u64 = undefined;
        for (0..len) |i| {
            a[i] = Self.frInt(i).init64();
        }
        break :blk a;
    };
    const zro: [len]u64 = blk: {
        var z: [Self.len]u64 = undefined;
        @memset(&z, 0);
        break :blk z;
    };
    cum_0,
    cum_1,
    cum_2,
    cum_3,
    cum_4,
    cum_5,
    cum_6,
    cum_7,
    cum_8,
    _,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(@min(n, len - 1));
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn inv(self: Self) CumUD {
        return CumUD.frInt(@max(0, 8 - self.toInt()));
    }

    pub fn init64(self: Self) u64 {
        var i: usize = self.toInt();
        if (i == 0) return 0;
        if (i >= len) return 0xffffffffffffffff;
        var cur = First;
        for (1..i) |j| cur |= First << 8 * j;
        return cur;
    }

    pub fn to64(self: Self) u64 {
        return arr[self.toInt()];
    }

    pub fn cup(enm: []Self) u64 {
        var pred: [len]bool = undefined;
        for (enm) |i| pred[i.toInt()] = true;
        return @reduce(std.builtin.ReduceOp.Or, @select(u64, pred, arr, zro));
    }
};

pub const CumUD = enum(u4) {
    const Self = @This();
    const First: u64 = 0xff;
    pub const len = 9;
    pub const arr: [len]u64 = blk: {
        var a: [Self.len]u64 = undefined;
        for (0..len) |i| {
            a[i] = Self.frInt(i).init64();
        }
        break :blk a;
    };
    const zro: [len]u64 = blk: {
        var z: [Self.len]u64 = undefined;
        @memset(&z, 0);
        break :blk z;
    };
    icum_0,
    icum_1,
    icum_2,
    icum_3,
    icum_4,
    icum_5,
    icum_6,
    icum_7,
    icum_8,
    _,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(@min(n, len - 1));
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn inv(self: Self) CumDU {
        return CumDU.frInt(@max(0, 8 - self.toInt()));
    }

    pub fn init64(self: Self) u64 {
        return ~self.inv().to64();
    }

    pub fn to64(self: Self) u64 {
        return arr[self.toInt()];
    }

    pub fn cup(enm: []Self) u64 {
        var pred: [len]bool = undefined;
        for (enm) |i| pred[i.toInt()] = true;
        return @reduce(std.builtin.ReduceOp.Or, @select(u64, pred, arr, zro));
    }
};

pub const Msk = enum(u5) {
    const Self = @This();
    pub const First: u64 = 0xffffffffffffffff;
    pub const arr: [len]u64 = blk: {
        var a: [Self.len]u64 = undefined;
        for (0..len) |i| {
            a[i] = Self.frInt(i).init64();
        }
        break :blk a;
    };
    const zro: [len]u64 = blk: {
        var z: [Self.len]u64 = undefined;
        @memset(&z, 0);
        break :blk z;
    };
    pub const len = 22;
    full,
    empty,
    rank_evens,
    rank_odds,
    file_evens,
    file_odds,
    rank_1256,
    rank_3478,
    file_abef,
    file_cdgh,
    rank_north,
    rank_south,
    file_west,
    file_east,
    edges,
    edges_2,
    edges_3,
    center,
    ext_center,
    dark,
    light,
    corners,
    _,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(@min(n, len - 1));
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn init64(self: Self) u64 {
        return switch (self) {
            .full => 0xffffffffffffffff,
            .empty => 0,
            .rank_evens => 0xff00ff00ff00ff00,
            .rank_odds => 0x00ff00ff00ff00ff,
            .file_evens => 0xaaaaaaaaaaaaaaaa,
            .file_odds => 0x5555555555555555,
            .rank_1256 => 0x0000ffff0000ffff,
            .rank_3478 => 0xffff0000ffff0000,
            .file_abef => 0x3333333333333333,
            .file_cdgh => 0xcccccccccccccccc,
            .rank_north => 0xffffffff00000000,
            .rank_south => 0x00000000ffffffff,
            .file_west => 0x0f0f0f0f0f0f0f0f,
            .file_east => 0xf0f0f0f0f0f0f0f0,
            .edges => 0xff818181818181ff,
            .edges_2 => 0x7e424242427e00,
            .edges_3 => 0x3c24243c0000,
            .center => 0x1818000000,
            .ext_center => 0x3c3c3c3c0000,
            .dark => 0xaa55aa55aa55aa55,
            .light => 0x55aa55aa55aa55aa,
            .corners => 0x8100000000000081,
            else => 0xffffffffffffffff,
        };
    }

    pub fn to64(self: Self) u64 {
        return arr[self.toInt()];
    }

    pub fn cup(enm: []Self) u64 {
        var pred: [len]bool = undefined;
        for (enm) |i| pred[i.toInt()] = true;
        return @reduce(std.builtin.ReduceOp.Or, @select(u64, pred, arr, zro));
    }
};

pub const Sqr = enum(u6) {
    const Self = @This();
    const First: u64 = 1;
    pub const len = 64;
    pub const arr: [len]u64 = blk: {
        var a: [Self.len]u64 = undefined;
        for (0..len) |i| {
            a[i] = Self.frInt(i).init64();
        }
        break :blk a;
    };
    const zro: [len]u64 = blk: {
        var z: [Self.len]u64 = undefined;
        @memset(&z, 0);
        break :blk z;
    };
    pub const Indexer = std.enums.EnumIndexer(Self);
    a1,
    b1,
    c1,
    d1,
    e1,
    f1,
    g1,
    h1,
    a2,
    b2,
    c2,
    d2,
    e2,
    f2,
    g2,
    h2,
    a3,
    b3,
    c3,
    d3,
    e3,
    f3,
    g3,
    h3,
    a4,
    b4,
    c4,
    d4,
    e4,
    f4,
    g4,
    h4,
    a5,
    b5,
    c5,
    d5,
    e5,
    f5,
    g5,
    h5,
    a6,
    b6,
    c6,
    d6,
    e6,
    f6,
    g6,
    h6,
    a7,
    b7,
    c7,
    d7,
    e7,
    f7,
    g7,
    h7,
    a8,
    b8,
    c8,
    d8,
    e8,
    f8,
    g8,
    h8,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(n);
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn rank(self: Self) Rnk {
        return Rnk.frInt(@truncate(self.toInt() / 8));
    }

    pub fn file(self: Self) Fil {
        return Fil.frInt(@truncate(self.toInt() % 8));
    }

    pub fn pdia(self: Self) PDia {
        return switch (self) {
            .a8 => .a8,
            .a7, .b8 => .a7b8,
            .a6, .b7, .c8 => .a6c8,
            .a5, .b6, .c7, .d8 => .a5d8,
            .a4, .b5, .c6, .d7, .e8 => .a4e8,
            .a3, .b4, .c5, .d6, .e7, .f8 => .a3f8,
            .a2, .b3, .c4, .d5, .e6, .f7, .g8 => .a2g8,
            .a1, .b2, .c3, .d4, .e5, .f6, .g7, .h8 => .a1h8,
            .b1, .c2, .d3, .e4, .f5, .g6, .h7 => .b1h7,
            .c1, .d2, .e3, .f4, .g5, .h6 => .c1h6,
            .d1, .e2, .f3, .g4, .h5 => .d1h5,
            .e1, .f2, .g3, .h4 => .e1h4,
            .f1, .g2, .h3 => .f1h3,
            .g1, .h2 => .g1h2,
            .h1 => .h1,
        };
    }

    pub fn ndia(self: Self) NDia {
        return switch (self) {
            .a1 => .a1,
            .a2, .b1 => .a2b1,
            .a3, .b2, .c1 => .a3c1,
            .a4, .b3, .c2, .d1 => .a4d1,
            .a5, .b4, .c3, .d2, .e1 => .a5e1,
            .a6, .b5, .c4, .d3, .e2, .f1 => .a6f1,
            .a7, .b6, .c5, .d4, .e3, .f2, .g1 => .a7g1,
            .a8, .b7, .c6, .d5, .e4, .f3, .g2, .h1 => .a8h1,
            .b8, .c7, .d6, .e5, .f4, .g3, .h2 => .b8h2,
            .c8, .d7, .e6, .f5, .g4, .h3 => .c8h3,
            .d8, .e7, .f6, .g5, .h4 => .d8h4,
            .e8, .f7, .g6, .h5 => .e8h5,
            .f8, .g7, .h6 => .f8h6,
            .g8, .h7 => .g8h7,
            .h8 => .h8,
        };
    }

    pub fn cup(enm: []Self) u64 {
        var pred: [len]bool = undefined;
        for (enm) |i| pred[i.toInt()] = true;
        return @reduce(std.builtin.ReduceOp.Or, @select(u64, pred, arr, zro));
    }

    pub fn init64(self: Self) u64 {
        return First << self.toInt();
    }

    pub fn to64(self: Self) u64 {
        return arr[self.toInt()];
    }

    pub fn toCol(self: Self) Col {
        return if (self.to64() & 0x55aa55aa55aa55aa != 0) .white else .black;
    }

    pub fn startingPiece(self: Self) ColPcs {
        var r = self.rank().toInt();
        var f = self.file().toInt();
        var player: Col = if (r < 2) .white else if (r < 6) .none else .black;
        if (player == .none) return .none;
        var mod: u3 = if (player == .black) 0 else 1;
        var piece: Pcs = if (r % 2 == mod)
            Pcs.p
        else if (f < 3)
            Pcs.frInt(f)
        else if (f == 3)
            Pcs.q
        else if (f == 4)
            Pcs.k
        else
            Pcs.frInt(0 -% f);
        return piece.toColPcs(player);
    }
};

pub const Cstl = enum(u4) { // KQkq
    const Self = @This();
    pub const len = 16;
    const qmsk: Self.tag() = 0b0001;
    const kmsk: Self.tag() = 0b0010;
    const Qmsk: Self.tag() = 0b0100;
    const Kmsk: Self.tag() = 0b1000;
    const bmsk: Self.tag() = 0b0011;
    const wmsk: Self.tag() = 0b1100;
    pub const arr: [len]u64 = blk: {
        var a: [Self.len]u64 = undefined;
        for (0..len) |i| {
            a[i] = Self.frInt(i).init64();
        }
        break :blk a;
    };

    none,
    q,
    k,
    kq,
    Q,
    Qq,
    Qk,
    Qkq,
    K,
    Kq,
    Kk,
    Kkq,
    KQ,
    KQq,
    KQk,
    KQkq,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(n);
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn init64(self: Self) u64 {
        var out: u64 = 0;
        var pos = self.toInt();
        if (pos & qmsk) out |= Sqr.a1;
        if (pos & kmsk) out |= Sqr.h1;
        if (pos & Qmsk) out |= Sqr.a8;
        if (pos & Kmsk) out |= Sqr.h8;
        return out;
    }

    pub fn to64(self: Self) u64 {
        return arr[self.toInt()];
    }
};

pub const EnPs = enum(u5) {
    const Self = @This();
    pub const len = 17;
    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    a,
    b,
    c,
    d,
    e,
    f,
    g,
    h,
    none,
    _,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(@min(n, len - 1));
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn to64(self: Self) u64 {
        if (self == .none) return 0;
        const i: u6 = self.toInt();
        const r: u6 = 24 * (i / 8) + 16;
        const f: u6 = i % 8;
        return (@as(u64, 1) << f) << r;
    }

    pub fn frColFil(col: Col, fil: Fil) Self {
        if (col == .none) return .none;
        const c: u5 = col.toInt();
        const f: u5 = fil.toInt();
        return frInt(f + 6 * c);
    }
};

pub const Shift = enum(i7) { // King + Knight Shifts
    const Self = @This();
    pub const len = 16;
    E = 1,
    ENE = 10,
    NE = 9,
    NNE = 17,
    N = 8,
    NNW = 15,
    NW = 7,
    WNW = 6,
    W = -1,
    WSW = -10,
    SW = -9,
    SSW = -17,
    S = -8,
    SSE = -15,
    SE = -7,
    ESE = -6,
    _,

    pub fn tag() type {
        return @typeInfo(Self).Enum.tag_type;
    }

    pub fn frInt(n: Self.tag()) Self {
        return @enumFromInt(n);
    }

    pub fn toInt(self: Self) Self.tag() {
        return @intFromEnum(self);
    }

    pub fn absInt(self: Self) u6 {
        return @truncate(std.math.absCast(self.toInt()));
    }

    pub fn lshift(self: Self) bool {
        const rd = self.rankDis();
        return if (rd != 0) rd > 0 else self.fileDis() > 0;
    }

    pub fn fileDis(self: Self) i4 {
        return switch (self) {
            .E => 1,
            .ENE => 2,
            .NE => 1,
            .NNE => 1,
            .N => 0,
            .NNW => -1,
            .NW => -1,
            .WNW => -2,
            .W => -1,
            .WSW => -2,
            .SW => -1,
            .SSW => -1,
            .S => 0,
            .SSE => 1,
            .SE => 1,
            .ESE => 2,
            else => 0,
        };
    }

    pub fn rankDis(self: Self) i4 {
        return switch (self) {
            .E => 0,
            .ENE => 1,
            .NE => 1,
            .NNE => 2,
            .N => 1,
            .NNW => 2,
            .NW => 1,
            .WNW => 1,
            .W => 0,
            .WSW => -1,
            .SW => -1,
            .SSW => -2,
            .S => -1,
            .SSE => -2,
            .SE => -1,
            .ESE => -1,
            else => 0,
        };
    }

    pub fn king() [8]Self {
        return [8]Self{ .E, .NE, .N, .NW, .W, .SW, .S, .SE };
    }

    pub fn knight() [8]Self {
        return [8]Self{ .ENE, .NNE, .NNW, .WNW, .WSW, .SSW, .SSE, .ESE };
    }
};
