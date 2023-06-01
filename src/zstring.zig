const std = @import("std");
const allocator = std.heap.c_allocator;
const string = @import("./zig-string.zig");

const zstring_t = opaque {};

const zstring_error_t = enum(c_int) {
    ZSTRING_ERROR_NONE,
    ZSTRING_ERROR_OUT_OF_MEMORY,
    ZSTRING_ERROR_INVALID_RANGE,
};

export fn zstring_init() ?*zstring_t {
    var str = allocator.create(string.String) catch return null;
    str.* = string.String.init(allocator);
    return @ptrCast(*zstring_t, str);
}

export fn zstring_init_with_contents(contents: ?[*:0]const u8, out_err: ?*zstring_error_t) ?*zstring_t {
    if (contents == null or out_err == null) return null;
    var str = allocator.create(string.String) catch return null;
    str.* = string.String.init_with_contents(allocator, std.mem.span(contents.?)) catch |err| {
        switch(err) {
            string.String.Error.OutOfMemory => {
                out_err.?.* = .ZSTRING_ERROR_OUT_OF_MEMORY;
                return null;
            },
            string.String.Error.InvalidRange => {
                out_err.?.* = .ZSTRING_ERROR_INVALID_RANGE;
                return null;
            },
        }
    };
    out_err.?.* = .ZSTRING_ERROR_NONE;
    return @ptrCast(*zstring_t, str);
}
