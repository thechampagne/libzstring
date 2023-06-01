const std = @import("std");
const allocator = std.heap.c_allocator;
const string = @import("./zig-string.zig");
const String = string.String;

const zstring_t = opaque {};

const zstring_error_t = enum(c_int) {
    ZSTRING_ERROR_NONE,
    ZSTRING_ERROR_OUT_OF_MEMORY,
    ZSTRING_ERROR_INVALID_RANGE,
};

export fn zstring_init() ?*zstring_t {
    var str = allocator.create(String) catch return null;
    str.* = String.init(allocator);
    return @ptrCast(*zstring_t, str);
}

export fn zstring_init_with_contents(contents: ?[*:0]const u8, out_err: ?*zstring_error_t) ?*zstring_t {
    if (contents == null or out_err == null) return null;
    var str = allocator.create(String) catch return null;
    str.* = String.init_with_contents(allocator, std.mem.span(contents.?)) catch |err| {
        switch (err) {
            String.Error.OutOfMemory => {
                out_err.?.* = .ZSTRING_ERROR_OUT_OF_MEMORY;
                return null;
            },
            String.Error.InvalidRange => {
                out_err.?.* = .ZSTRING_ERROR_INVALID_RANGE;
                return null;
            },
        }
    };
    out_err.?.* = .ZSTRING_ERROR_NONE;
    return @ptrCast(*zstring_t, str);
}

export fn zstring_deinit(self: ?*zstring_t) void {
    if (self) |sf| {
        zstringCast(sf).deinit();
    }
}

export fn zstring_capacity(self: ?*const zstring_t) usize {
    if (self) |sf| {
        return zstringCast(@constCast(sf)).capacity();
    }
    return 0;
}

export fn zstring_allocate(self: ?*zstring_t, bytes: usize) zstring_error_t {
    zstringCast(self.?).allocate(bytes) catch |err| {
        switch (err) {
            String.Error.OutOfMemory => {
                return .ZSTRING_ERROR_OUT_OF_MEMORY;
            },
            String.Error.InvalidRange => {
                return .ZSTRING_ERROR_INVALID_RANGE;
            },
        }
    };
    return .ZSTRING_ERROR_NONE;
}

export fn zstring_truncate(self: ?*zstring_t) zstring_error_t {
    zstringCast(self.?).truncate() catch |err| {
        switch (err) {
            String.Error.OutOfMemory => {
                return .ZSTRING_ERROR_OUT_OF_MEMORY;
            },
            String.Error.InvalidRange => {
                return .ZSTRING_ERROR_INVALID_RANGE;
            },
        }
    };
    return .ZSTRING_ERROR_NONE;
}

export fn zstring_concat(self: ?*zstring_t, char: ?[*:0]const u8) zstring_error_t {
    zstringCast(self.?).concat(std.mem.span(char.?)) catch |err| {
        switch (err) {
            String.Error.OutOfMemory => {
                return .ZSTRING_ERROR_OUT_OF_MEMORY;
            },
            String.Error.InvalidRange => {
                return .ZSTRING_ERROR_INVALID_RANGE;
            },
        }
    };
    return .ZSTRING_ERROR_NONE;
}

export fn zstring_insert(self: ?*zstring_t, literal: ?[*:0]const u8, index: usize) zstring_error_t {
    zstringCast(self.?).insert(std.mem.span(literal.?), index) catch |err| {
        switch (err) {
            String.Error.OutOfMemory => {
                return .ZSTRING_ERROR_OUT_OF_MEMORY;
            },
            String.Error.InvalidRange => {
                return .ZSTRING_ERROR_INVALID_RANGE;
            },
        }
    };
    return .ZSTRING_ERROR_NONE;
}

export fn zstring_pop(self: ?*zstring_t, len: ?*usize) ?[*]const u8 {
    var pop = zstringCast(self.?).pop() orelse return null;
    len.?.* = pop.len;
    return pop.ptr;
}

export fn zstring_cmp(self: ?*const zstring_t, literal: ?[*:0]const u8) c_int {
    if (zstringCast(@constCast(self.?)).cmp(std.mem.span(literal.?))) return 1;
    return 0;
}

export fn zstring_str(self: ?*const zstring_t, len: ?*usize) ?[*]const u8 {
    var str = zstringCast(@constCast(self.?)).str();
    len.?.* = str.len;
    return str.ptr;
}

// NOTE: must be freed
export fn zstring_to_owned(self: ?*const zstring_t, out_err: ?*zstring_error_t, len: ?*usize) ?[*]u8 {
    var to_owned = zstringCast(@constCast(self.?)).toOwned() catch |err| {
        switch (err) {
            String.Error.OutOfMemory => {
                out_err.?.* = .ZSTRING_ERROR_OUT_OF_MEMORY;
                return null;
            },
            String.Error.InvalidRange => {
                out_err.?.* = .ZSTRING_ERROR_INVALID_RANGE;
                return null;
            },
        }
    } orelse return null;
    out_err.?.* = .ZSTRING_ERROR_NONE;
    len.?.* = to_owned.len;
    return to_owned.ptr;
}

inline fn zstringCast(zstring: *zstring_t) *String {
    return @ptrCast(*String, @alignCast(8, zstring));
}
