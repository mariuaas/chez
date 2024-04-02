const std = @import("std");
const math = std.math;
const EnumArray = std.EnumArray;
const builtin = @import("builtin");

fn BBArr(comptime n: comptime_int) type {
    return struct {
        index: [n]u64,
        const len = n;
        const Self = @This();

        fn init(data: [n]u64) Self {
            return Self{ .index = data };
        }
    };
}

pub const RANK = BBArr(8).init(blk: {
    comptime var vals: [8]u64 = undefined;
    for (0..8) |i| vals[i] = 0xff << (i * 8);
    break :blk vals;
});

pub const FILE = BBArr(8).init(blk: {
    comptime var vals: [8]u64 = undefined;
    for (0..8) |i| vals[i] = 0x0101010101010101 << i;
    break :blk vals;
});

pub const SQUARE = BBArr(64).init(blk: {
    comptime var vals: [64]u64 = undefined;
    for (0..64) |i| vals[i] = (1 << i);
    break :blk vals;
});

pub const POSDIAG = BBArr(15).init(blk: {
    comptime var vals: [15]u64 = undefined;
    comptime var cnt: i8 = -7;
    for (0..15) |j| {
        comptime var abs: u6 = @truncate(math.absCast(cnt));
        comptime var stp: u6 = 8 - abs;
        comptime var cur: u64 = 1 << ((if (cnt <= 0) 8 else 1) * abs);
        comptime var res: u64 = 0;
        for (0..stp) |i| {
            comptime var shift: u6 = @truncate(9 * i);
            res |= cur << shift;
        }
        cnt += 1;
        vals[j] = res;
    }
    break :blk vals;
});

pub const NEGDIAG = BBArr(15).init(blk: {
    comptime var vals: [15]u64 = undefined;
    comptime var cnt: i8 = -7;
    for (0..15) |j| {
        comptime var abs: u6 = @truncate(math.absCast(cnt));
        comptime var stp: u6 = 8 - abs;
        comptime var cur: u64 = 1 << ((if (cnt <= 0) 1 else 8) * abs);
        comptime var res: u64 = 0;
        for (0..stp) |i| {
            comptime var shift: u6 = @truncate(7 * i);
            res |= cur >> shift;
        }
        cnt += 1;
        vals[j] = res;
    }
    break :blk vals;
});

pub const CUMFILE = BBArr(9).init(blk: {
    comptime var vals: [9]u64 = undefined;
    comptime var mask: u64 = 0;
    vals[0] = mask;
    for (1..9) |i| {
        mask |= FILE[i];
        vals[i] = mask;
    }
    break :blk vals;
});

// pub const RANK = packed struct {
//     pub const _1: u64 = 0xff << (0 * 8);
//     pub const _2: u64 = 0xff << (1 * 8);
//     pub const _3: u64 = 0xff << (2 * 8);
//     pub const _4: u64 = 0xff << (3 * 8);
//     pub const _5: u64 = 0xff << (4 * 8);
//     pub const _6: u64 = 0xff << (5 * 8);
//     pub const _7: u64 = 0xff << (6 * 8);
//     pub const _8: u64 = 0xff << (7 * 8);
// };

pub fn main() void {
    for (NEGDIAG.index) |bits| {
        std.debug.print("{x:016}\n", .{bits});
    }
}
