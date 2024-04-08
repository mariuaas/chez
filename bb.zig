const std = @import("std");
const enums = @import("enums.zig");
const repr = @import("repr.zig");

const Pcs = enums.Pcs;
const Col = enums.Col;
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

pub const BB = packed struct {
    const Self = @This();
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

    // Init methods
    pub fn fr64(board: u64) Self {
        return @bitCast(board);
    }

    fn frEnum(comptime T: type) type {
        return struct {
            pub fn get(e: T) Self {
                return fr64(e.to64());
            }
        };
    }

    // // This makes less sense when including the BBVec type...
    // pub fn fr(e: anytype) Self {
    //     const T = comptime @TypeOf(e);
    //     if (comptime std.meta.trait.hasFn("to64")(T)) {
    //         return fr64(e.to64());
    //     }
    //     return Self{};
    // }

    pub fn frSqr(e: Sqr) Self {
        return frEnum(Sqr).get(e);
    }

    pub fn frFil(e: Fil) Self {
        return frEnum(Fil).get(e);
    }

    pub fn frRnk(e: Rnk) Self {
        return frEnum(Rnk).get(e);
    }

    pub fn frPDia(e: PDia) Self {
        return frEnum(PDia).get(e);
    }

    pub fn frNDia(e: NDia) Self {
        return frEnum(NDia).get(e);
    }

    pub fn frCumLR(e: CumLR) Self {
        return frEnum(CumLR).get(e);
    }

    pub fn frCumDU(e: CumDU) Self {
        return frEnum(CumDU).get(e);
    }

    pub fn frCumRL(e: CumRL) Self {
        return frEnum(CumRL).get(e);
    }

    pub fn frCumUD(e: CumUD) Self {
        return frEnum(CumUD).get(e);
    }

    pub fn frMsk(e: Msk) Self {
        return frEnum(Msk).get(e);
    }

    pub fn frCstl(e: Cstl) Self {
        return frEnum(Cstl).get(e);
    }

    pub fn frEmps(e: EnPs) Self {
        return frEnum(EnPs).get(e);
    }

    pub fn frSqrs(sqrs: []Sqr) Self {
        return fr64(Sqr.cup(sqrs));
    }

    // Conversion methods
    pub fn to64(self: Self) u64 {
        return @bitCast(self);
    }

    pub fn toBoolArr(self: Self) [64]bool {
        return @bitCast(self);
    }

    pub fn toBoolVec(self: Self) @Vector(64, bool) {
        return self.toArr();
    }

    pub fn toBitSet(self: Self) std.bit_set.IntegerBitSet(64) {
        return std.bit_set.IntegerBitSet(64){ .mask = self.to64() };
    }

    // Unary ops
    pub fn chkSqr(self: Self, sqr: Sqr) bool {
        return self.to64() & sqr.to64() > 0;
    }

    pub fn setSqr(self: Self, sqr: Sqr) BB {
        return fr64(self.to64() | @as(u64, 1) << sqr.toInt());
    }

    pub fn clrSqr(self: Self, sqr: Sqr) BB {
        return fr64(self.to64() & ~(@as(u64, 1) << sqr.toInt()));
    }

    pub fn tglSqr(self: Self, sqr: Sqr) BB {
        return fr64(self.to64() ^ @as(u64, 1) << sqr.toInt());
    }

    pub fn neg(self: Self) Self {
        return fr64(-self.to64());
    }

    pub fn negWrap(self: Self) Self {
        return fr64(-%self.to64());
    }

    pub fn inv(self: Self) Self {
        return fr64(~self.to64());
    }

    pub fn flipud(self: Self) Self {
        const k1 = Msk.rank_odds.to64();
        const k2 = Msk.rank_1256.to64();
        var x = self.to64();
        x = ((x >> 8) & k1) | ((x & k1) << 8);
        x = ((x >> 16) & k2) | ((x & k2) << 16);
        x = (x >> 32) | (x << 32);
        return fr64(x);
    }

    pub fn fliplr(self: Self) Self {
        const k1 = Msk.file_odds.to64();
        const k2 = Msk.file_abef.to64();
        const k4 = Msk.file_west.to64();
        var x = self.to64();
        x = ((x >> 1) & k1) + 2 * (x & k1);
        x = ((x >> 2) & k2) + 4 * (x & k2);
        x = ((x >> 4) & k4) + 16 * (x & k4);
        return fr64(x);
    }

    pub fn rev(self: Self) Self {
        return @bitReverse(self.to64());
    }

    pub fn lsb(self: Self) u7 {
        return @ctz(self.to64());
    }

    pub fn msb(self: Self) u7 {
        return @clz(self.to64());
    }

    pub fn popcnt(self: Self) u7 {
        return @popCount(self.to64());
    }

    // Shift and attacks
    pub fn shiftN(self: Self, i: u3) Self {
        fr64(return self.to64() << 8 * @as(u6, i));
    }

    pub fn shiftS(self: Self, i: u3) Self {
        return fr64(self.to64() >> 8 * @as(u6, i));
    }

    pub fn shiftW(self: Self, i: u3) Self {
        var mask = CumLR.frInt(i + 1).to64();
        return fr64((self.to64() >> i) & mask);
    }

    pub fn shiftE(self: Self, i: u3) Self {
        var mask = CumRL.frInt(i).to64();
        return fr64((self.to64() << i) & mask);
    }

    pub fn shiftNW(self: Self, i: u3) Self {
        var mask = CumLR.frInt(i + 1).to64();
        return fr64((self.to64() << 7 * @as(u6, i)) & mask);
    }

    pub fn shiftNE(self: Self, i: u3) Self {
        var mask = CumRL.frInt(i).to64();
        return fr64((self.to64() << 9 * @as(u6, i)) & mask);
    }

    pub fn shiftSW(self: Self, i: u3) Self {
        var mask = CumLR.frInt(i + 1).to64();
        return fr64((self.to64() >> 9 * @as(u6, i)) & mask);
    }

    pub fn shiftSE(self: Self, i: u3) Self {
        var mask = CumRL.frInt(i).to64();
        return fr64((self.to64() >> 7 * @as(u6, i)) & mask);
    }

    pub fn kAtt(self: Self) Self {
        return fr64(self.shiftE(1).to64() |
            self.shiftNE(1).to64() |
            self.shiftN(1).to64() |
            self.shiftNW(1).to64() |
            self.shiftW(1).to64() |
            self.shiftSW(1).to64() |
            self.shiftS(1).to64() |
            self.shiftSE(1).to64());
    }

    pub fn nAtt(self: Self) Self {
        return fr64(self.shiftE(1).shiftNE(1).to64() |
            self.shiftN(1).shiftNW(1).to64() |
            self.shiftN(1).shiftNE(1).to64() |
            self.shiftW(1).shiftNW(1).to64() |
            self.shiftW(1).shiftSW(1).to64() |
            self.shiftS(1).shiftSW(1).to64() |
            self.shiftS(1).shiftSE(1).to64() |
            self.shiftE(1).shiftSE(1).to64());
    }

    pub fn hypQ(self: Self, occ: Self) Self {
        const a = occ.subWrap(self.mulWrap(2));
        const b = occ.rev().subWrap(self.rev().mulWrap(2)).rev();
        return a.xor(b);
    }

    // Binary ops
    pub fn add(self: Self, other: Self) Self {
        return fr64(self.to64() + other.to64());
    }

    pub fn addWrap(self: Self, other: Self) Self {
        return fr64(self.to64() +% other.to64());
    }

    pub fn sub(self: Self, other: Self) Self {
        return fr64(self.to64() - other.to64());
    }

    pub fn subWrap(self: Self, other: Self) Self {
        return fr64(self.to64() -% other.to64());
    }

    pub fn mul(self: Self, other: Self) Self {
        return fr64(self.to64() * other.to64());
    }

    pub fn mulWrap(self: Self, other: Self) Self {
        return fr64(self.to64() *% other.to64());
    }

    pub fn cap(self: Self, other: Self) Self {
        return fr64(self.to64() & other.to64());
    }

    pub fn cup(self: Self, other: Self) Self {
        return fr64(self.to64() | other.to64());
    }

    pub fn xor(self: Self, other: Self) Self {
        return fr64(self.to64() ^ other.to64());
    }

    pub fn lt(self: Self, other: Self) Self {
        return fr64(self.to64() < other.to64());
    }

    pub fn gt(self: Self, other: Self) Self {
        return fr64(self.to64() > other.to64());
    }

    pub fn lte(self: Self, other: Self) bool {
        return self.to64() <= other.to64();
    }

    pub fn gte(self: Self, other: Self) bool {
        return self.to64() >= other.to64();
    }

    pub fn eql(self: Self, other: Self) bool {
        return self.to64() == other.to64();
    }

    pub fn subset(self: Self, other: Self) bool {
        var o = other.to64();
        return (self.to64() | o) == o;
    }

    pub fn supset(self: Self, other: Self) bool {
        return subset(other, self);
    }

    // Iterator and formatting

    pub fn iter(self: Self) Serializer {
        return Serializer{ .bits = self.to64() };
    }

    pub fn format(
        self: Self,
        comptime fmt: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        var brd: repr.Boards = comptime blk: {
            var itr = std.mem.tokenize(u8, fmt, "|");
            while (itr.next()) |opt| {
                if (@hasField(repr.Boards, opt)) {
                    break :blk @field(repr.Boards, opt);
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

pub fn BBVec(comptime n: comptime_int) type {
    return packed struct {
        const Self = @This();

        const u64_0: @Vector(n, u64) = @splat(0);
        const u64_1: @Vector(n, u64) = @splat(1);
        const u64_2: @Vector(n, u64) = @splat(2);
        const u64_4: @Vector(n, u64) = @splat(4);
        const u64_8: @Vector(n, u64) = @splat(8);
        const u64_16: @Vector(n, u64) = @splat(16);
        const u64_32: @Vector(n, u64) = @splat(32);

        const u6_1: @Vector(n, u6) = @splat(1);
        const u6_2: @Vector(n, u6) = @splat(2);
        const u6_4: @Vector(n, u6) = @splat(4);
        const u6_8: @Vector(n, u6) = @splat(8);
        const u6_16: @Vector(n, u6) = @splat(16);
        const u6_32: @Vector(n, u6) = @splat(32);

        bbs: @Vector(n, u64) = @splat(0x0),

        // Init methods
        pub fn fr64(boards: @Vector(n, u64)) Self {
            return @bitCast(boards);
        }

        pub fn frBB(boards: [n]BB) Self {
            return @bitCast(boards);
        }

        // Splat methods
        pub fn splat64(val: u64) Self {
            const spl: @Vector(n, u64) = @splat(val);
            return fr64(spl);
        }

        fn splatEnum(comptime T: type) type {
            return struct {
                pub fn get(e: T) Self {
                    return splat64(e.to64());
                }
            };
        }

        pub fn splatSqr(e: Sqr) Self {
            return splatEnum(Sqr).get(e);
        }

        pub fn splatFil(e: Fil) Self {
            return splatEnum(Fil).get(e);
        }

        pub fn splatRnk(e: Rnk) Self {
            return splatEnum(Rnk).get(e);
        }

        pub fn splatPDia(e: PDia) Self {
            return splatEnum(PDia).get(e);
        }

        pub fn splatNDia(e: NDia) Self {
            return splatEnum(NDia).get(e);
        }

        pub fn splatCumLR(e: CumLR) Self {
            return splatEnum(CumLR).get(e);
        }

        pub fn splatCumDU(e: CumDU) Self {
            return splatEnum(CumDU).get(e);
        }

        pub fn splatCumRL(e: CumRL) Self {
            return splatEnum(CumRL).get(e);
        }

        pub fn splatCumUD(e: CumUD) Self {
            return splatEnum(CumUD).get(e);
        }

        pub fn splatMsk(e: Msk) Self {
            return splatEnum(Msk).get(e);
        }

        pub fn splatCstl(e: Cstl) Self {
            return splatEnum(Cstl).get(e);
        }

        pub fn splatEnPs(e: EnPs) Self {
            return splatEnum(EnPs).get(e);
        }

        pub fn splatSqrs(sqrs: []Sqr) Self {
            const spl: @Vector(n, u64) = @splat(Sqr.cup(sqrs));
            return fr64(spl);
        }

        // Conversion methods
        pub fn to64(self: Self) @Vector(n, u64) {
            return @bitCast(self);
        }

        pub fn toBB(self: Self) [n]BB {
            return @bitCast(self);
        }

        // Unary ops
        pub fn chkSqr(self: Self, sqr: Sqr) @Vector(n, bool) {
            const spl: @Vector(n, u64) = @splat(sqr.to64());
            return self.to64() & spl > u64_0;
        }

        pub fn setSqr(self: Self, sqr: Sqr) BB {
            const spl: @Vector(n, u64) = @splat(sqr.to64());
            return fr64(self.to64() | u64_1 << spl.toInt());
        }

        pub fn clrSqr(self: Self, sqr: Sqr) BB {
            const spl: @Vector(n, u64) = @splat(sqr.to64());
            return fr64(self.to64() & ~(u64_1 << spl.toInt()));
        }

        pub fn tglSqr(self: Self, sqr: Sqr) BB {
            const spl: @Vector(n, u64) = @splat(sqr.to64());
            return fr64(self.to64() ^ u64_1 << spl.toInt());
        }

        pub fn neg(self: Self) Self {
            return fr64(-self.to64());
        }

        pub fn negWrap(self: Self) Self {
            return fr64(-%self.to64());
        }

        pub fn inv(self: Self) Self {
            return fr64(~self.to64());
        }

        pub fn flipud(self: Self) Self {
            const k1 = Self.splatMsk(.rank_odds).to64();
            const k2 = Self.splatMsk(.rank_1256).to64();
            var x = self.to64();
            x = ((x >> u6_8) & k1) | ((x & k1) << u6_8);
            x = ((x >> u6_16) & k2) | ((x & k2) << u6_16);
            x = (x >> u6_32) | (x << u6_32);
            return fr64(x);
        }

        pub fn fliplr(self: Self) Self {
            const k1 = Self.splatMsk(.file_odds).to64();
            const k2 = Self.splatMsk(.file_abef).to64();
            const k4 = Self.splatMsk(.file_west).to64();
            var x = self.to64();
            x = ((x >> u6_1) & k1) + u64_2 * (x & k1);
            x = ((x >> u6_2) & k2) + u64_4 * (x & k2);
            x = ((x >> u6_4) & k4) + u64_16 * (x & k4);
            return fr64(x);
        }

        pub fn rev(self: Self) Self {
            return fr64(@bitReverse(self.to64()));
        }

        pub fn lsb(self: Self) @Vector(n, u7) {
            return @ctz(self.to64());
        }

        pub fn msb(self: Self) @Vector(n, u7) {
            return @clz(self.to64());
        }

        pub fn popcnt(self: Self) @Vector(n, u7) {
            return @popCount(self.to64());
        }

        pub fn redCup(self: Self) BB {
            return BB.fr64(@reduce(.Or, self.bbs));
        }

        pub fn redCap(self: Self) BB {
            return BB.fr64(@reduce(.And, self.bbs));
        }

        // Shift Ops
        pub fn shiftN(self: Self, i: u3) Self {
            const spl: @Vector(n, u6) = @splat(8 * @as(u6, i));
            return fr64(self.to64() << spl);
        }

        pub fn shiftS(self: Self, i: u3) Self {
            const spl: @Vector(n, u6) = @splat(8 * @as(u6, i));
            return fr64(self.to64() >> spl);
        }

        pub fn shiftW(self: Self, i: u3) Self {
            const mask = Self.splatCumLR(CumLR.frInt(i + 1)).to64();
            const spl: @Vector(n, u6) = @splat(@as(u6, i));
            return fr64((self.to64() >> spl) & mask);
        }

        pub fn shiftE(self: Self, i: u3) Self {
            const mask = Self.splatCumRL(CumRL.frInt(i)).to64();
            const spl: @Vector(n, u6) = @splat(@as(u6, i));
            return fr64((self.to64() << spl) & mask);
        }

        pub fn shiftNW(self: Self, i: u3) Self {
            const mask = Self.splatCumLR(CumLR.frInt(i + 1)).to64();
            const spl: @Vector(n, u6) = @splat(7 * @as(u6, i));
            return fr64((self.to64() << spl) & mask);
        }

        pub fn shiftNE(self: Self, i: u3) Self {
            const mask = Self.splatCumRL(CumRL.frInt(i)).to64();
            const spl: @Vector(n, u6) = @splat(9 * @as(u6, i));
            return fr64((self.to64() << spl) & mask);
        }

        pub fn shiftSW(self: Self, i: u3) Self {
            const mask: @Vector(n, u64) = @splat(CumLR.arr[8 - @as(u4, i)]);
            const spl: @Vector(n, u6) = @splat(9 * @as(u6, i));
            return fr64((self.to64() >> spl) & mask);
        }

        pub fn shiftSE(self: Self, i: u3) Self {
            const mask: @Vector(n, u64) = @splat(CumLR.arr[i]);
            const spl: @Vector(n, u6) = @splat(7 * @as(u6, i));
            return fr64((self.to64() >> spl) & ~mask);
        }

        // Binary ops
        pub fn add(self: Self, other: Self) Self {
            return fr64(self.to64() + other.to64());
        }

        pub fn addWrap(self: Self, other: Self) Self {
            return fr64(self.to64() +% other.to64());
        }

        pub fn sub(self: Self, other: Self) Self {
            return fr64(self.to64() - other.to64());
        }

        pub fn subWrap(self: Self, other: Self) Self {
            return fr64(self.to64() -% other.to64());
        }

        pub fn mul(self: Self, other: Self) Self {
            return fr64(self.to64() * other.to64());
        }

        pub fn mulWrap(self: Self, other: Self) Self {
            return fr64(self.to64() *% other.to64());
        }

        pub fn cap(self: Self, other: Self) Self {
            return fr64(self.to64() & other.to64());
        }

        pub fn cup(self: Self, other: Self) Self {
            return fr64(self.to64() | other.to64());
        }

        pub fn xor(self: Self, other: Self) Self {
            return fr64(self.to64() ^ other.to64());
        }

        pub fn lt(self: Self, other: Self) Self {
            return fr64(self.to64() < other.to64());
        }

        pub fn gt(self: Self, other: Self) Self {
            return fr64(self.to64() > other.to64());
        }

        pub fn lte(self: Self, other: Self) @Vector(n, bool) {
            return self.to64() <= other.to64();
        }

        pub fn gte(self: Self, other: Self) @Vector(n, bool) {
            return self.to64() >= other.to64();
        }

        pub fn eql(self: Self, other: Self) @Vector(n, bool) {
            return self.to64() == other.to64();
        }

        pub fn subset(self: Self, other: Self) @Vector(n, bool) {
            var o = other.to64();
            return (self.to64() | o) == o;
        }

        pub fn supset(self: Self, other: Self) @Vector(n, bool) {
            return subset(other, self);
        }
    };
}

pub fn main() void {
    // var val = BB.frPDia(.a4e8);
    // std.debug.print("{}", .{val});
    // std.debug.print("{}", .{val.shiftE(5)});
    // var tst: @Vector(4, u64) = [4]u64{
    //     BB.frPDia(.a4e8).to64(),
    //     BB.frRnk(._2).to64(),
    //     BB.frFil(.a).to64(),
    //     BB.frCumDU(.c3).to64(),
    // };
    // var pcnt = @ctz(tst);
    // var bv = BBVec(4).fr64(tst);
    // std.debug.print("{any}\n", .{pcnt});
    // std.debug.print("{any}\n\n", .{bv});
    var bbs = [4]BB{
        BB.frPDia(.a4e8),
        BB.frRnk(._2),
        BB.frFil(.a),
        BB.frCumDU(.c3),
    };
    var bv = BBVec(4).frBB(bbs).shiftNE(3);
    std.debug.print("{}", .{bv.toBB()[1]});
    // std.debug.print("{}", .{bbv.bbs[1]});
}
