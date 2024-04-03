const std = @import("std");
const math = std.math;
const ReduceOp = std.builtin.ReduceOp;

pub fn FileFactory() type {
    return packed struct {
        const Self = @This();
        a: u64,
        b: u64,
        c: u64,
        d: u64,
        e: u64,
        f: u64,
        g: u64,
        h: u64,

        fn arr(self: Self) [8]u64 {
            return @as([8]u64, @bitCast(self));
        }

        fn idx(self: Self, n: usize) u64 {
            return self.arr()[n];
        }

        fn vec(self: Self) @Vector(8, u64) {
            return self.arr();
        }

        fn cup(self: Self) u64 {
            return @reduce(ReduceOp.Or, self.vec());
        }

        fn cap(self: Self) u64 {
            return @reduce(ReduceOp.And, self.vec());
        }
    };
}

pub const file = blk_outer: {
    comptime var instance: FileFactory() = @bitCast(blk: {
        comptime var vals: [8]u64 = undefined;
        for (0..8) |i| vals[i] = 0x0101010101010101 << i;
        break :blk vals;
    });
    break :blk_outer instance;
};

pub fn RankFactory() type {
    return packed struct {
        const Self = @This();
        _1: u64,
        _2: u64,
        _3: u64,
        _4: u64,
        _5: u64,
        _6: u64,
        _7: u64,
        _8: u64,

        fn arr(self: Self) [8]u64 {
            return @as([8]u64, @bitCast(self));
        }

        fn idx(self: Self, n: usize) u64 {
            return self.arr()[n];
        }

        fn vec(self: Self) @Vector(8, u64) {
            return self.arr();
        }

        fn cup(self: Self) u64 {
            return @reduce(ReduceOp.Or, self.vec());
        }

        fn cap(self: Self) u64 {
            return @reduce(ReduceOp.And, self.vec());
        }
    };
}

pub const rank = blk_outer: {
    comptime var instance: RankFactory() = @bitCast(blk: {
        comptime var vals: [8]u64 = undefined;
        for (0..8) |i| vals[i] = 0xff << (i * 8);
        break :blk vals;
    });
    break :blk_outer instance;
};

pub fn SquareFactory() type {
    return packed struct {
        const Self = @This();
        a1: u64,
        b1: u64,
        c1: u64,
        d1: u64,
        e1: u64,
        f1: u64,
        g1: u64,
        h1: u64,
        a2: u64,
        b2: u64,
        c2: u64,
        d2: u64,
        e2: u64,
        f2: u64,
        g2: u64,
        h2: u64,
        a3: u64,
        b3: u64,
        c3: u64,
        d3: u64,
        e3: u64,
        f3: u64,
        g3: u64,
        h3: u64,
        a4: u64,
        b4: u64,
        c4: u64,
        d4: u64,
        e4: u64,
        f4: u64,
        g4: u64,
        h4: u64,
        a5: u64,
        b5: u64,
        c5: u64,
        d5: u64,
        e5: u64,
        f5: u64,
        g5: u64,
        h5: u64,
        a6: u64,
        b6: u64,
        c6: u64,
        d6: u64,
        e6: u64,
        f6: u64,
        g6: u64,
        h6: u64,
        a7: u64,
        b7: u64,
        c7: u64,
        d7: u64,
        e7: u64,
        f7: u64,
        g7: u64,
        h7: u64,
        a8: u64,
        b8: u64,
        c8: u64,
        d8: u64,
        e8: u64,
        f8: u64,
        g8: u64,
        h8: u64,

        fn arr(self: Self) [64]u64 {
            return @as([64]u64, @bitCast(self));
        }

        fn idx(self: Self, n: usize) u64 {
            return self.arr()[n];
        }

        fn vec(self: Self) @Vector(64, u64) {
            return self.arr();
        }

        fn cup(self: Self) u64 {
            return @reduce(ReduceOp.Or, self.vec());
        }

        fn cap(self: Self) u64 {
            return @reduce(ReduceOp.And, self.vec());
        }
    };
}

pub const square = blk_outer: {
    comptime var instance: SquareFactory() = @bitCast(blk: {
        comptime var vals: [64]u64 = undefined;
        for (0..64) |i| vals[i] = (1 << i);
        break :blk vals;
    });
    break :blk_outer instance;
};

pub fn PosDiagFactory() type {
    return packed struct {
        const Self = @This();
        a8: u64,
        a7b8: u64,
        a6c8: u64,
        a5d8: u64,
        a4e8: u64,
        a3f8: u64,
        a2g8: u64,
        a1h8: u64,
        b1h7: u64,
        c1h6: u64,
        d1h5: u64,
        e1h4: u64,
        f1h3: u64,
        g1h2: u64,
        h1: u64,

        fn arr(self: Self) [15]u64 {
            return @as([15]u64, @bitCast(self));
        }

        fn idx(self: Self, n: usize) u64 {
            return self.arr()[n];
        }

        fn vec(self: Self) @Vector(15, u64) {
            return self.arr();
        }

        fn cup(self: Self) u64 {
            return @reduce(ReduceOp.Or, self.vec());
        }

        fn cap(self: Self) u64 {
            return @reduce(ReduceOp.And, self.vec());
        }
    };
}

pub const posDiag = blk_outer: {
    comptime var instance: PosDiagFactory() = @bitCast(blk: {
        comptime var vals: [15]u64 = undefined;
        comptime var diag: u64 = 0x8040201008040201;
        for (0..15) |i| {
            if (i < 8) {
                vals[i] = (diag << (56 - 8 * i));
            } else {
                vals[i] = diag >> (8 * i - 56);
            }
        }
        break :blk vals;
    });
    break :blk_outer instance;
};

pub fn NegDiagFactory() type {
    return packed struct {
        const Self = @This();
        a1: u64,
        a2b1: u64,
        a3c1: u64,
        a4d1: u64,
        a5e1: u64,
        a6f1: u64,
        a7g1: u64,
        a8h1: u64,
        b8h2: u64,
        c8h3: u64,
        d8h4: u64,
        e8h5: u64,
        f8h6: u64,
        g8h7: u64,
        h8: u64,

        fn arr(self: Self) [15]u64 {
            return @as([15]u64, @bitCast(self));
        }

        fn idx(self: Self, n: usize) u64 {
            return self.arr()[n];
        }

        fn vec(self: Self) @Vector(15, u64) {
            return self.arr();
        }

        fn cup(self: Self) u64 {
            return @reduce(ReduceOp.Or, self.vec());
        }

        fn cap(self: Self) u64 {
            return @reduce(ReduceOp.And, self.vec());
        }
    };
}

pub const negDiag = blk_outer: {
    comptime var instance: NegDiagFactory() = @bitCast(blk: {
        comptime var vals: [15]u64 = undefined;
        comptime var diag: u64 = 0x0102040810204080;
        for (0..15) |i| {
            if (i < 8) {
                vals[14 - i] = (diag << (56 - 8 * i));
            } else {
                vals[14 - i] = diag >> (8 * i - 56);
            }
        }
        break :blk vals;
    });
    break :blk_outer instance;
};

pub fn CumFileFactory() type {
    return packed struct {
        const Self = @This();
        cz: u64,
        ca: u64,
        cb: u64,
        cc: u64,
        cd: u64,
        ce: u64,
        cf: u64,
        cg: u64,
        ch: u64,

        fn arr(self: Self) [9]u64 {
            return @as([9]u64, @bitCast(self));
        }

        fn idx(self: Self, n: usize) u64 {
            return self.arr()[n];
        }

        fn vec(self: Self) @Vector(9, u64) {
            return self.arr();
        }

        fn cup(self: Self) u64 {
            return @reduce(ReduceOp.Or, self.vec());
        }

        fn cap(self: Self) u64 {
            return @reduce(ReduceOp.And, self.vec());
        }
    };
}

pub const cumFile = blk_outer: {
    comptime var instance: CumFileFactory() = @bitCast(blk: {
        comptime var vals: [9]u64 = undefined;
        comptime var cur: u64 = 0;
        vals[0] = cur;
        for (0..8) |i| {
            cur |= file.idx(i);
            vals[i + 1] = cur;
        }
        break :blk vals;
    });
    break :blk_outer instance;
};

pub fn CumRankFactory() type {
    return packed struct {
        const Self = @This();
        c0: u64,
        c1: u64,
        c2: u64,
        c3: u64,
        c4: u64,
        c5: u64,
        c6: u64,
        c7: u64,
        c8: u64,

        fn arr(self: Self) [9]u64 {
            return @as([9]u64, @bitCast(self));
        }

        fn idx(self: Self, n: usize) u64 {
            return self.arr()[n];
        }

        fn vec(self: Self) @Vector(9, u64) {
            return self.arr();
        }

        fn cup(self: Self) u64 {
            return @reduce(ReduceOp.Or, self.vec());
        }

        fn cap(self: Self) u64 {
            return @reduce(ReduceOp.And, self.vec());
        }
    };
}

pub const cumRank = blk_outer: {
    comptime var instance: CumFileFactory() = @bitCast(blk: {
        comptime var vals: [9]u64 = undefined;
        comptime var cur: u64 = 0;
        vals[0] = cur;
        for (0..8) |i| {
            cur |= rank.idx(i);
            vals[i + 1] = cur;
        }
        break :blk vals;
    });
    break :blk_outer instance;
};

pub fn MaskFactory() type {
    return packed struct {
        const Self = @This();
        full: u64,
        empty: u64,
        rank_evens: u64,
        rank_odds: u64,
        file_evens: u64,
        file_odds: u64,
        rank_1256: u64,
        rank_3478: u64,
        file_abef: u64,
        file_cdgh: u64,
        rank_north: u64,
        rank_south: u64,
        file_west: u64,
        file_east: u64,
        edges: u64,
        edges_2: u64,
        edges_3: u64,
        center: u64,
        ext_center: u64,
        dark: u64,
        light: u64,
        corners: u64,

        fn arr(self: Self) [9]u64 {
            return @as([9]u64, @bitCast(self));
        }

        fn idx(self: Self, n: usize) u64 {
            return self.arr()[n];
        }

        fn vec(self: Self) @Vector(9, u64) {
            return self.arr();
        }

        fn cup(self: Self) u64 {
            return @reduce(ReduceOp.Or, self.vec());
        }

        fn cap(self: Self) u64 {
            return @reduce(ReduceOp.And, self.vec());
        }
    };
}

pub const mask = blk_outer: {
    comptime var instance: MaskFactory() = @bitCast([_]u64{
        0xffffffffffffffff,
        0,
        0xff00ff00ff00ff00,
        0x00ff00ff00ff00ff,
        0xaaaaaaaaaaaaaaaa,
        0x5555555555555555,
        0x0000ffff0000ffff,
        0xffff0000ffff0000,
        0x3333333333333333,
        0xcccccccccccccccc,
        0xffffffff00000000,
        0x00000000ffffffff,
        0x0f0f0f0f0f0f0f0f,
        0xf0f0f0f0f0f0f0f0,
        0xff818181818181ff,
        0x7e424242427e00,
        0x3c24243c0000,
        0x1818000000,
        0x3c3c3c3c0000,
        0xaa55aa55aa55aa55,
        0x55aa55aa55aa55aa,
        0x8100000000000081,
    });
    break :blk_outer instance;
};

pub fn main() void {
    for (cumRank.arr()) |bits| {
        std.debug.print("{x:016}\n", .{bits});
    }
}
