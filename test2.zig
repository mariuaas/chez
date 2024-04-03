const std = @import("std");

pub fn structArray(comptime fields: []const []const u8) type {
    var f: [fields.len + 1]std.builtin.Type.StructField = undefined;
    for (fields, 0..fields.len) |name, i| {
        f[i] = std.builtin.Type.StructField{
            .name = name,
            .type = u64,
            .default_value = null,
            .is_comptime = false,
            .alignment = 0,
        };
    }
    f[fields.len] = std.builtin.Type.StructField{
        .name = "index",
        .type = *[fields.len]u64,
        .default_value = null,
        .is_comptime = false,
        .alignment = 0,
    };

    return @Type(.{
        .Struct = .{
            .layout = .Packed,
            .fields = &f,
            .decls = &[_]std.builtin.Type.Declaration{},
            .is_tuple = false,
        },
    });
}

pub fn initStructArray(comptime fields: []const []const u8, comptime values: []const u64) structArray(fields) {
    const T = structArray(fields);
    var instance: T = undefined;
    inline for (fields, values) |field, value| {
        @field(instance, field) = value;
    }
    @field(instance, "index") = @ptrCast(&instance);
    return instance;
}

pub const E = packed struct {
    v1: u64,
    v2: u64,
    v3: u64,
};

pub fn main() void {
    var vec3 = initStructArray(&[_][]const u8{ "x", "y", "z" }, &[_]u64{ 1, 2, 3 });
    for (0..vec3.index.len) |i| {
        std.debug.print("Field {any}: {any}\n", .{ vec3.index[i], i });
    }
    var e: E = @bitCast([_]u64{ 1, 2, 3 });
    std.debug.print("{d}\n", .{e.v1});
    // for (0..3) |i| {
    //     std.debug.print("{d}\n", .{pck[i]});
    // }
}
