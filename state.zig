const std = @import("std");
const enums = @import("enums.zig");
const repr = @import("repr.zig");
const bb = @import("bb.zig");

const Turn = enums.Turn;
const Col = enums.Col;
const Pcs = enums.Pcs;
const ColPcs = enums.ColPcs;
const Sqr = enums.Sqr;
const Fil = enums.Fil;
const Rnk = enums.Rnk;
const PDia = enums.PDia;
const NDia = enums.NDia;
const CumLR = enums.CumLR;
const CumDU = enums.CumDU;
const CumRL = enums.CumRL;
const CumUD = enums.CumUD;
const Msk = enums.Msk;
const Cstl = enums.Cstl;
const EnPs = enums.EnPs;
const BB = bb.BB;
const BBVec = bb.BBVec;

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

    pub fn to64(self: Self) @Vector(len, u64) {
        return @bitCast(self);
    }

    pub fn toBB(self: Self) BBVec(len) {
        return @bitCast(self.to64());
    }

    pub fn splatCap(self: Self, brd: BB) BBVec(len) {
        const msk = BBVec(6).splat64(brd.to64());
        return self.toBB().cap(msk);
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

    pub fn to64(self: Self) @Vector(len, u64) {
        return @bitCast(self);
    }

    pub fn toBB(self: Self) BBVec(len) {
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

    pub fn to64(self: Self) @Vector(len, u64) {
        return @bitCast(self);
    }

    pub fn toBB(self: Self) BBVec(len) {
        return @bitCast(self.to64());
    }

    pub fn colPcsVec(self: Self) BBVec(12) {
        const whts = self.pcs.splatCap(self.col.white);
        const blks = self.pcs.splatCap(self.col.black);
        return BBVec(12).fr64(std.simd.join(whts.to64(), blks.to64()));
    }

    pub fn getColPcs(self: Self, colpcs: ColPcs) BB {
        if (colpcs == .none) return BB{};
        const bv = self.colPcsVec();
        return BB.fr64(bv.bbs[colpcs.toInt()]);
    }

    pub fn sqrToColPcs(self: Self, sqr: Sqr) ColPcs {
        const msk = BBVec(12).splatSqr(sqr);
        const bv = self.colPcsVec();
        const idx: u4 = std.simd.firstTrue(msk.subset(bv)) orelse return .none;
        return @enumFromInt(idx);
    }

    pub fn occ(self: Self) BB {
        return self.col.white.cup(self.col.black);
    }
};

pub const State = packed struct {
    const Self = @This();
    colpcs: ColPcsState = ColPcsState{},
    cstl: Cstl = .KQkq,
    enps: EnPs = .none,
    turn: Turn = .white,
    move: u14 = 0,

    pub fn clear(self: Self) void {
        self.colpcs.clear();
        self.cstl = .none;
        self.enps = .none;
        self.turn = .white;
        self.move = 0;
    }

    pub fn occ(self: Self) BB {
        return self.colpcs.occ();
    }

    pub fn sqrToColPcs(self: Self, sqr: Sqr) ColPcs {
        return self.colpcs.sqrToColPcs(sqr);
    }

    pub fn getColPcs(self: Self, e: ColPcs) BB {
        return self.colpcs.getColPcs(e);
    }

    pub fn allies(self: Self, col: Col) BB {
        return switch (col) {
            .white => self.colpcs.col.white,
            .black => self.colpcs.col.black,
            else => BB.frMsk(.empty),
        };
    }

    pub fn enemies(self: Self, col: Col) BB {
        return switch (col) {
            .white => self.colpcs.col.black,
            .black => self.colpcs.col.white,
            else => BB.frMsk(.empty),
        };
    }

    pub fn pAtt(self: Self, sqr: Sqr, col: Col) BB {
        const p = BB.frSqr(sqr);
        const e = self.enemies(col);
        const o = self.occ();
        if (self.turn == .white) {
            const rnk = BB.frRnk(._2);
            const mvs = p.shiftN(1).cup(p.cap(rnk).shiftN(2));
            const att = p.shiftNE(1).cup(p.shiftNW(1));
            return mvs.cap(o.inv()).cup(att.cap(e));
        }
        const rnk = BB.frRnk(._7);
        const mvs = p.shiftS(1).cup(p.cap(rnk).shiftS(2));
        const att = p.shiftSE(1).cup(p.shiftSW(1));
        return mvs.cap(o.inv()).cup(att.cap(e));
    }

    pub fn nAtt(_: Self, sqr: Sqr) BB {
        return BB.frSqr(sqr).nAtt();
    }

    pub fn bAtt(self: Self, sqr: Sqr) BB {
        const p = BB.frSqr(sqr);
        const o = self.occ();
        const pd = BB.frPDia(sqr.pdia());
        const nd = BB.frNDia(sqr.ndia());
        return p.hypQ(o.cap(nd)).cap(nd).cup(p.hypQ(o.cap(pd)).cap(pd));
    }

    pub fn rAtt(self: Self, sqr: Sqr) BB {
        const p = BB.frSqr(sqr);
        const o = self.occ();
        const f = BB.frFil(sqr.file());
        const r = BB.frRnk(sqr.rank());
        return p.hypQ(o.cap(r)).cap(r).cup(p.hypQ(o.cap(f)).cap(f));
    }

    pub fn qAtt(self: Self, sqr: Sqr) BB {
        return self.rAtt(sqr).cup(self.bAtt(sqr));
    }

    pub fn kAtt(_: Self, sqr: Sqr) BB {
        return BB.frSqr(sqr).kAtt();
    }

    pub fn attacks(self: Self, sqr: Sqr) BB {
        const colpcs = self.sqrToColPcs(sqr);
        const nall = self.allies(colpcs.toCol()).inv();
        return switch (colpcs.toPcs()) {
            .p => self.pAtt(sqr, colpcs.toCol()),
            .n => self.nAtt(sqr).cap(nall),
            .b => self.bAtt(sqr).cap(nall),
            .r => self.rAtt(sqr).cap(nall),
            .q => self.qAtt(sqr).cap(nall),
            .k => self.kAtt(sqr).cap(nall),
            else => BB.frMsk(.empty),
        };
    }

    pub fn attackers(self: Self, sqr: Sqr) BB {
        const colpcs = self.sqrToColPcs(sqr);
        const col = colpcs.toCol();
        const nall = self.allies(colpcs.toCol()).inv();
        var a: BB = undefined;
        if (col == .none) {
            a = self.pAtt(sqr, .black).cup(self.pAtt(sqr, .white));
        } else {
            a = self.pAtt(sqr, col.opp());
        }
        a = a.cup(self.nAtt(sqr).cap(self.colpcs.pcs.n));
        a = a.cup(self.bAtt(sqr).cap(self.colpcs.pcs.b));
        a = a.cup(self.rAtt(sqr).cap(self.colpcs.pcs.r));
        a = a.cup(self.qAtt(sqr).cap(self.colpcs.pcs.q));
        a = a.cup(self.kAtt(sqr).cap(self.colpcs.pcs.k));
        return a.cap(nall);
    }
};

pub fn main() void {
    var state = State{};
    // std.debug.print("{fancy|P}", .{BB.fr64(state.p)});
    std.debug.print("{}\n", .{state.colpcs.pcs.p});
    std.debug.print("{}\n", .{state.getColPcs(.R)});
    std.debug.print("{}\n", .{state.sqrToColPcs(.c3)});
    std.debug.print("{}\n", .{state.attacks(.b1)});
    std.debug.print("{}\n", .{state.attacks(.g8)});
    std.debug.print("{}\n", .{state.attackers(.h6)});
    // std.debug.print("{}\n", .{BB.frSqr(.d4).nAtt()});
    // std.debug.print("{}\n", .{BB.frSqr(.d4).shiftW(1)});
    // std.debug.print("{}\n", .{BB.frCumRL(CumRL.frInt(2))});
    // std.debug.print("{}\n", .{BB.frCumLR(CumLR.frInt(2))});
    // std.debug.print("{}\n", .{BB.frCumUD(CumUD.frInt(2))});
    // std.debug.print("{}\n", .{BB.frCumDU(CumDU.frInt(2))});
}
