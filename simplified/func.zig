const std = @import("std");

const BB = @import("bb.zig").BB;
const Msk = @import("cnst.zig").Msk;
const CumRL = @import("cnst.zig").CumRL;
const CumLR = @import("cnst.zig").CumLR;
const Shift = @import("cnst.zig").Shift;

pub fn len64(comptime T: type) comptime_int {
    return switch (@typeInfo(T)) {
        .Array => |info| info.len,
        .Vector => |info| info.len,
        .Struct, .Enum, .Union, .Opaque => if (@hasDecl(T, "len")) T.len else 1,
        .Int, .ComptimeInt => 1,
        else => comptime {
            @compileError(std.fmt.comptimePrint("Unsupported type: {any}", .{T}));
        },
    };
}

pub fn Vec(comptime T: type, comptime U: type) type {
    return @Vector(len64(T), U);
}

pub fn Splat(comptime T: type) type {
    return struct {
        pub fn to(comptime U: type, u: U) Vec(T, U) {
            return @splat(u);
        }

        pub fn to64(comptime V: type, v: V) Vec(T, u64) {
            const u: u64 = switch (@typeInfo(V)) {
                .Int, .ComptimeInt => @truncate(v),
                .Struct, .Enum, .Union, .Opaque => if (comptime std.meta.trait.hasFn("to64")(V)) v.to64() else comptime {
                    @compileError(std.fmt.comptimePrint("Unsupported type: {any}", .{V}));
                },
                else => comptime {
                    @compileError(std.fmt.comptimePrint("Unsupported type: {any}", .{V}));
                },
            };
            return @splat(u);
        }
    };
}

pub fn Reduce(comptime T: type, comptime U: type, comptime op: std.builtin.ReduceOp) fn (T) U {
    const Closure = struct {
        pub fn reduce(t: T) U {
            @reduce(op, t);
        }
    };
    return Closure.reduce;
}

pub fn flipud(comptime T: type, t: T) Vec(T, u64) {
    const splat = Splat(T);
    const k1 = splat.to64(Msk, .rank_odds);
    const k2 = splat.to64(Msk, .rank_1256);
    const u6_8 = splat.to(u6, 8);
    const u6_16 = splat.to(u6, 16);
    const u6_32 = splat.to(u6, 32);
    var bits: Vec(T, u64) = @bitCast(t);
    bits = ((bits >> u6_8) & k1) | ((bits & k1) << u6_8);
    bits = ((bits >> u6_16) & k2) | ((bits & k2) << u6_16);
    bits = (bits >> u6_32) | (bits << u6_32);
    return bits;
}

pub fn fliplr(comptime T: type, t: T) Vec(T, u64) {
    const splat = Splat(T);
    const k1 = splat.to64(Msk, .file_odds);
    const k2 = splat.to64(Msk, .file_abef);
    const k4 = splat.to64(Msk, .file_west);
    const u64_2 = splat.to(u64, 2);
    const u64_4 = splat.to(u64, 4);
    const u64_16 = splat.to(u64, 16);
    const u6_1 = splat.to(u6, 1);
    const u6_2 = splat.to(u6, 2);
    const u6_4 = splat.to(u6, 4);
    var bits: Vec(T, u64) = @bitCast(t);
    bits = ((bits >> u6_1) & k1) + u64_2 * (bits & k1);
    bits = ((bits >> u6_2) & k2) + u64_4 * (bits & k2);
    bits = ((bits >> u6_4) & k4) + u64_16 * (bits & k4);
    return bits;
}

pub fn rev(comptime T: type, t: T) Vec(T, u64) {
    const bits: Vec(T, u64) = @bitCast(t);
    return @bitReverse(bits);
}

pub fn lsb(comptime T: type, t: T) Vec(T, u7) {
    const bits: Vec(T, u64) = @bitCast(t);
    return @ctz(bits);
}

pub fn msb(comptime T: type, t: T) Vec(T, u7) {
    const bits: Vec(T, u64) = @bitCast(t);
    return @clz(bits);
}

pub fn popcnt(comptime T: type, t: T) Vec(T, u7) {
    const bits: Vec(T, u64) = @bitCast(t);
    return @popCount(bits);
}

pub fn shift(comptime T: type, t: T, sh: Shift) Vec(T, u64) {
    const splat = Splat(T);
    const st = sh.fileDis();
    const s = splat.to(u6, sh.absInt());
    const bits: Vec(T, u64) = @bitCast(t);
    const mask = if (st > 0)
        splat.to64(CumLR, CumLR.frInt(std.math.absCast(st)))
    else
        splat.to64(CumRL, CumRL.frInt(std.math.absCast(st)));
    return if (sh.lshift()) (bits << s) & ~mask else (bits >> s) & ~mask;
}

pub fn shiftN(comptime T: type, t: T, st: u3) Vec(T, u64) {
    const s: Vec(T, u6) = @splat(8 * @as(u6, st));
    const bits: Vec(T, u64) = @bitCast(t);
    return bits << s;
}

pub fn shiftS(comptime T: type, t: T, st: u3) Vec(T, u64) {
    const s: Vec(T, u6) = @splat(8 * @as(u6, st));
    const bits: Vec(T, u64) = @bitCast(t);
    return bits >> s;
}

pub fn shiftW(comptime T: type, t: T, st: u3) Vec(T, u64) {
    const splat = Splat(T);
    const s: Vec(T, u6) = @splat(@as(u6, st));
    const mask = splat.to64(CumRL, CumRL.frInt(st));
    const bits: Vec(T, u64) = @bitCast(t);
    return (bits >> s) & ~mask;
}

pub fn shiftE(comptime T: type, t: T, st: u3) Vec(T, u64) {
    const splat = Splat(T);
    const s: Vec(T, u6) = @splat(@as(u6, st));
    const mask = splat.to64(CumLR, CumLR.frInt(st));
    const bits: Vec(T, u64) = @bitCast(t);
    return (bits << s) & ~mask;
}

pub fn shiftNW(comptime T: type, t: T, st: u3) Vec(T, u64) {
    const splat = Splat(T);
    const s: Vec(T, u6) = @splat(7 * @as(u6, st));
    const mask = splat.to64(CumRL, CumRL.frInt(st));
    const bits: Vec(T, u64) = @bitCast(t);
    return (bits << s) & ~mask;
}

pub fn shiftNE(comptime T: type, t: T, st: u3) Vec(T, u64) {
    const splat = Splat(T);
    const s: Vec(T, u6) = @splat(9 * @as(u6, st));
    const mask = splat.to64(CumLR, CumLR.frInt(st));
    const bits: Vec(T, u64) = @bitCast(t);
    return (bits << s) & ~mask;
}

pub fn shiftSW(comptime T: type, t: T, st: u3) Vec(T, u64) {
    const splat = Splat(T);
    const s: Vec(T, u6) = @splat(9 * @as(u6, st));
    const mask = splat.to64(CumRL, CumRL.frInt(st));
    const bits: Vec(T, u64) = @bitCast(t);
    return (bits >> s) & ~mask;
}

pub fn shiftSE(comptime T: type, t: T, st: u3) Vec(T, u64) {
    const splat = Splat(T);
    const s: Vec(T, u6) = @splat(7 * @as(u6, st));
    const mask = splat.to64(CumLR, CumLR.frInt(st));
    const bits: Vec(T, u64) = @bitCast(t);
    return (bits >> s) & ~mask;
}

pub fn kAttack(comptime T: type, t: T) Vec(T, u64) {
    const splat = Splat(T);
    const bits: Vec(T, u64) = @bitCast(t);
    var out = splat.to64(Msk, .empty);
    for (Shift.king()) |sh| out |= shift(Vec(T, u64), bits, sh);
    return out;
}

pub fn nAttack(comptime T: type, t: T) Vec(T, u64) {
    const splat = Splat(T);
    const bits: Vec(T, u64) = @bitCast(t);
    var out = splat.to64(Msk, .empty);
    for (Shift.knight()) |sh| out |= shift(Vec(T, u64), bits, sh);
    return out;
}

pub fn main() void {
    var z = flipud(u64, 0x0001000000);
    std.debug.print("{any}\n", .{z});
    var b = BB.fr64(0x000100000);
    var d = flipud(BB, b);
    std.debug.print("{any}\n", .{d});
    var e = shift(BB, b, .SW);
    std.debug.print("{any}\n", .{e});
    var f = shiftSW(BB, b, 1);
    std.debug.print("{any}\n", .{f});

    std.debug.print("{any}", .{b});
    var be: BB = @bitCast(e);
    var bf: BB = @bitCast(f);
    std.debug.print("{any}", .{be});
    std.debug.print("{any}", .{bf});

    var k = kAttack(BB, b);
    var n = nAttack(BB, b);
    var bk: BB = @bitCast(k);
    var bn: BB = @bitCast(n);
    std.debug.print("{fancy|K}\n", .{bk});
    std.debug.print("{fancy|N}\n", .{bn});
}
