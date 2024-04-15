const std = @import("std");
const F = @import("func.zig");

const BB = @import("bb.zig").BB;
const Col = @import("cnst.zig").Col;
const Pcs = @import("cnst.zig").Pcs;
const ColPcs = @import("cnst.zig").ColPcs;
const Sqr = @import("cnst.zig").Sqr;
const Fil = @import("cnst.zig").Fil;
const Rnk = @import("cnst.zig").Rnk;
const PDia = @import("cnst.zig").PDia;
const NDia = @import("cnst.zig").NDia;
const CumLR = @import("cnst.zig").CumLR;
const CumDU = @import("cnst.zig").CumDU;
const CumRL = @import("cnst.zig").CumRL;
const CumUD = @import("cnst.zig").CumUD;
const Msk = @import("cnst.zig").Msk;
const Cstl = @import("cnst.zig").Cstl;
const EnPs = @import("cnst.zig").EnPs;

// TODO: Lots of stuff

pub const State = packed struct {
    const Self = @This();
    pub const len = 10;
    p: BB = BB.fr64(Rnk._2.to64() | Rnk._7.to64()),
    n: BB = BB.fr64(Sqr.b1.to64() | Sqr.g1.to64() | Sqr.b8.to64() | Sqr.g8.to64()),
    b: BB = BB.fr64(Sqr.c1.to64() | Sqr.f1.to64() | Sqr.c8.to64() | Sqr.f8.to64()),
    r: BB = BB.fr64(Sqr.a1.to64() | Sqr.h1.to64() | Sqr.a8.to64() | Sqr.h8.to64()),
    q: BB = BB.fr64(Sqr.d1.to64() | Sqr.d8.to64()),
    k: BB = BB.fr64(Sqr.e1.to64() | Sqr.e8.to64()),
    white: BB = BB.fr64(Rnk._1.to64() | Rnk._2.to64()),
    black: BB = BB.fr64(Rnk._7.to64() | Rnk._8.to64()),
    cstl: BB = BB.fr(Msk, .corners),
    enps: BB = BB.fr(Msk, .empty),
};

pub const PcsState = packed struct {
    const Self = @This();
    pub const len = 6;
    p: BB = BB.fr64(Rnk._2.to64() | Rnk._7.to64()),
    n: BB = BB.fr64(Sqr.b1.to64() | Sqr.g1.to64() | Sqr.b8.to64() | Sqr.g8.to64()),
    b: BB = BB.fr64(Sqr.c1.to64() | Sqr.f1.to64() | Sqr.c8.to64() | Sqr.f8.to64()),
    r: BB = BB.fr64(Sqr.a1.to64() | Sqr.h1.to64() | Sqr.a8.to64() | Sqr.h8.to64()),
    q: BB = BB.fr64(Sqr.d1.to64() | Sqr.d8.to64()),
    k: BB = BB.fr64(Sqr.e1.to64() | Sqr.e8.to64()),

    pub fn clear(self: Self) void {
        self.p = BB{};
        self.n = BB{};
        self.b = BB{};
        self.r = BB{};
        self.q = BB{};
        self.k = BB{};
    }

    pub fn to64(self: Self) F.Vec(Self, u64) {
        return @bitCast(self);
    }

    pub fn toArr(self: Self) [len]BB {
        return @bitCast(self.to64());
    }
};

pub const ColState = packed struct {
    const Self = @This();
    pub const len = 2;
    white: BB = BB.fr64(Rnk._1.to64() | Rnk._2.to64()),
    black: BB = BB.fr64(Rnk._7.to64() | Rnk._8.to64()),

    pub fn clear(self: Self) void {
        self.white = BB{};
        self.black = BB{};
    }

    pub fn to64(self: Self) F.Vec(Self, u64) {
        return @bitCast(self);
    }

    pub fn toArr(self: Self) [len]BB {
        return @bitCast(self.to64());
    }
};

pub const ColPcsState = packed struct {
    const Self = @This();
    pub const len = 8;
    pcs: PcsState = PcsState{},
    col: ColState = ColState{},

    pub fn clear(self: Self) void {
        self.pcs.clear();
        self.col.clear();
    }

    pub fn to64(self: Self) F.Vec(Self, u64) {
        return @bitCast(self);
    }

    pub fn toArr(self: Self) [len]BB {
        return @bitCast(self.to64());
    }

    pub fn colPcsVec(self: Self) [12]BB {
        _ = self; // TODO: Add function in func
        const out: [12]BB = undefined;
        return out;
    }

    pub fn getColPcs(self: Self, colpcs: ColPcs) BB {
        if (colpcs == .none) return BB{};
        const bv = self.colPcsVec();
        return BB.fr64(bv.bbs[colpcs.toInt()]);
    }

    pub fn sqrToColPcs(self: Self, sqr: Sqr) ColPcs {
        const splat = F.Splat([12]BB);
        const msk = splat.to64(Sqr, sqr);
        const bv = self.colPcsVec();
        const idx: u4 = std.simd.firstTrue(msk.subset(bv)) orelse return .none;
        return @enumFromInt(idx);
    }

    pub fn occ(self: Self) BB {
        return self.col.white.cup(self.col.black);
    }
};
