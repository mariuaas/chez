const std = @import("std");
const cnst = @import("cnst.zig");

const simd = std.simd;
const ReduceOp = std.builtin.ReduceOp;
const Pcs = cnst.Pcs;
const Col = cnst.Col;

pub fn rnglen(comptime start: i32, comptime stop: i32, comptime step: i32) comptime_int {
    if (step == 0) comptime @compileError("Invalid step of zero.");
    const res = (stop - start) / step;
    if (res < 0) comptime @compileError(std.fmt.comptimePrint("Invalid range length: {d}.", .{res}));
    return res;
}

pub fn rngchk(comptime start: i32, comptime stop: i32, comptime step: i32) comptime_int {
    comptime return std.math.absCast((stop - start) / step);
}

pub fn AsI(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .Int, .ComptimeInt => std.meta.Int(.signed, @bitSizeOf(T)),
        else => comptime {
            @compileError(std.fmt.comptimePrint("No signedness for {any}.", .{T}));
        },
    };
}

pub fn AsU(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .Int, .ComptimeInt => std.meta.Int(.unsigned, @bitSizeOf(T)),
        else => comptime {
            @compileError(std.fmt.comptimePrint("No signedness for {any}.", .{T}));
        },
    };
}

pub fn RngSign(comptime T: type, comptime start: i32, comptime stop: i32, comptime step: i32) type {
    const res: @Vector(3, bool) = [3]bool{ start < 0, stop < 0, step < 0 };
    return if (@reduce(.Or, res)) AsI(T) else T;
}

pub fn RngVec(comptime T: type, comptime start: i32, comptime stop: i32, comptime step: i32) type {
    return Vec(RngSign(T, start, stop, step), rnglen(start, stop, step));
}

pub fn Vec(comptime T: type, comptime len: comptime_int) type {
    return @Vector(len, T);
}

pub fn Zeros(comptime T: type, comptime len: comptime_int) Vec(T, len) {
    return @splat(@as(T, 0));
}

pub fn Ones(comptime T: type, comptime len: comptime_int) Vec(T, len) {
    return @splat(@as(T, 1));
}

pub fn Fill(comptime T: type, comptime len: comptime_int, val: T) Vec(T, len) {
    return @splat(@as(T, val));
}

pub fn Range(
    comptime T: type,
    comptime start: i32,
    comptime stop: i32,
    comptime step: i32,
) RngVec(T, start, stop, step) {
    const len = rnglen(start, stop, step);
    const ResType = RngVec(T, start, stop, step);
    const Child = std.meta.Child(ResType);
    const o = Ones(T, len);
    const m: ResType = Fill(Child, len, step);
    const s: ResType = Fill(Child, len, start);
    const res: ResType = simd.prefixScan(.Add, 1, o) - o;
    return res * m + s;
}

pub fn StateVec(comptime rows: comptime_int) type {
    return Vec(u64, rows * 10);
}

pub fn statePcs(comptime rows: comptime_int, comptime pcs: Pcs, state: StateVec(rows)) Vec(u64, rows) {
    const start: u32 = comptime pcs.toInt();
    const mask = comptime Range(i32, start, 10 * rows + start, 10);
    return @shuffle(u64, state, undefined, mask);
}

pub fn stateCol(comptime rows: comptime_int, comptime col: Col, state: StateVec(rows)) Vec(u64, rows) {
    const start = @as(u32, comptime col.toInt()) + 6;
    const mask = comptime Range(i32, start, 10 * rows + start, 10);
    return @shuffle(u64, state, undefined, mask);
}

pub fn stateOcc(comptime rows: comptime_int, state: StateVec(rows)) Vec(u64, rows) {
    const white = stateCol(rows, .white, state);
    const black = stateCol(rows, .black, state);
    return white | black;
}

pub fn SentinelIterator(comptime T: type, comptime len: comptime_int) type {
    return struct {
        const Self = @This();
        const sentinel = std.math.maxInt(T);
        arr: [len]T,
        i: usize = 0,
        pub fn next(self: *Self) ?T {
            const cur = self.arr[self.i];
            if (cur != sentinel) {
                self.i += 1;
                return cur;
            }
            return null;
        }
    };
}

pub fn where(comptime len: comptime_int, pred: Vec(bool, len)) SentinelIterator(i32, len) {
    const It = SentinelIterator(i32, len);
    const rng = Range(i32, 0, len, 1);
    const mxv = Fill(i32, len, It.sentinel);
    var arr: [len]i32 = @select(i32, pred, rng, mxv);
    std.mem.sort(i32, &arr, {}, comptime std.sort.asc(i32));
    return It{ .arr = arr };
}

// // NOTE: Unfinished
// pub fn VecSerializer(comptime rows: comptime_int, bits: Vec(u64, rows)) type {
//     return struct {
//         const S = @This();
//         const chk = Fill(u7, rows, 64);
//         const zro = Zeros(u64, rows);
//         const one = Ones(u64, rows);
//         cur: Vec(u64, rows) = bits,

//         pub fn next(s: S) ?Vec(u64, rows) {
//             const pos = @ctz(s.bits);
//             if (@reduce(.And, pos == S.chk)) return null;

//             s.cur &= ~(S.one << @truncate(pos));
//         }
//     };
// }

pub fn main() void {
    const nv = 24;
    var rng = Range(u64, 0, nv, 1);
    var two = Fill(u64, nv, 2);
    var one = Ones(u64, nv);

    var it = where(nv, rng % two == one);
    while (it.next()) |a| {
        std.debug.print("{d} ", .{a});
    }
}
