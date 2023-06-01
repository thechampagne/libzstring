const std = @import("std");
const assert = std.debug.assert;
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

export fn zstring_char_at(self: ?*const zstring_t, index: usize, len: ?*usize) ?[*]const u8 {
    var char_at = zstringCast(@constCast(self.?)).charAt(index)  orelse return null;
    len.?.* = char_at.len;
    return char_at.ptr;
}

export fn zstring_len(self: ?*const zstring_t) usize {
    return zstringCast(@constCast(self.?)).len();
}

export fn zstring_find(self: ?*const zstring_t, literal: ?[*:0]const u8) usize {
    return zstringCast(@constCast(self.?)).find(std.mem.span(literal.?)) orelse return 0;
}

export fn zstring_remove(self: ?*zstring_t, index: usize) zstring_error_t {
    zstringCast(self.?).remove(index) catch |err| {
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

export fn zstring_remove_range(self: ?*zstring_t, start: usize, end: usize) zstring_error_t {
    zstringCast(self.?).removeRange(start, end) catch |err| {
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

export fn zstring_trim_start(self: ?*zstring_t, whitelist: ?[*:0]const u8) void {
    zstringCast(self.?).trimStart(std.mem.span(whitelist.?));
}

export fn zstring_trim_end(self: ?*zstring_t, whitelist: ?[*:0]const u8) void {
    zstringCast(self.?).trimEnd(std.mem.span(whitelist.?));
}

export fn zstring_trim(self: ?*zstring_t, whitelist: ?[*:0]const u8) void {
    zstringCast(self.?).trim(std.mem.span(whitelist.?));
}

export fn zstring_clone(self: ?*const zstring_t, out_err: ?*zstring_error_t) ?*zstring_t {
    var clone = zstringCast(@constCast(self.?)).clone() catch |err| {
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
    var str = allocator.create(String) catch return null;
    str.* = clone;
    out_err.?.* = .ZSTRING_ERROR_NONE;
    return @ptrCast(*zstring_t, str);
}

export fn zstring_reverse(self: ?*zstring_t) void {
    zstringCast(self.?).reverse();
}

export fn zstring_repeat(self: ?*zstring_t, n: usize) zstring_error_t {
    zstringCast(self.?).repeat(n) catch |err| {
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

export fn zstring_is_empty(self: ?*const zstring_t) c_int {
    if (zstringCast(@constCast(self.?)).isEmpty()) return 1;
    return 0;
}

export fn zstring_split(self: ?*const zstring_t, delimiters: ?[*:0]const u8, index: usize, len: ?*usize) ?[*]const u8 {
    var split = zstringCast(@constCast(self.?)).split(std.mem.span(delimiters.?), index) orelse return null;
    len.?.* = split.len;
    return split.ptr;
}

export fn zstring_split_to_zstring(self: ?*const zstring_t, delimiters: ?[*:0]const u8, index: usize, out_err: ?*zstring_error_t) ?*zstring_t {
    var clone = zstringCast(@constCast(self.?)).splitToString(std.mem.span(delimiters.?), index) catch |err| {
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
    var str = allocator.create(String) catch return null;
    str.* = clone;
    out_err.?.* = .ZSTRING_ERROR_NONE;
    return @ptrCast(*zstring_t, str);
}

export fn zstring_clear(self: ?*zstring_t) void {
    zstringCast(self.?).clear();
}

export fn zstring_to_lowercase(self: ?*zstring_t) void {
    zstringCast(self.?).toLowercase();
}

export fn zstring_to_uppercase(self: ?*zstring_t) void {
    zstringCast(self.?).toUppercase();
}

export fn zstring_substr(self: ?*const zstring_t, start: usize, end: usize, out_err: ?*zstring_error_t) ?*zstring_t {
    var substr = zstringCast(@constCast(self.?)).substr(start, end) catch |err| {
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
    var str = allocator.create(String) catch return null;
    str.* = substr;
    out_err.?.* = .ZSTRING_ERROR_NONE;
    return @ptrCast(*zstring_t, str);
}

inline fn zstringCast(zstring: *zstring_t) *String {
    return @ptrCast(*String, @alignCast(8, zstring));
}

test "Basic Usage" {

    // Create your String
    var myString = zstring_init();
    defer zstring_deinit(myString);
    
    // Use functions provided
    _ = zstring_concat(myString,"🔥 Hello!");
    var output_len: usize = undefined;
    _ = zstring_pop(myString, &output_len);
    _ = zstring_concat(myString, ", World 🔥");

    // Success!
    assert(zstring_cmp(myString, "🔥 Hello, World 🔥") == 1);
}

// test "String Tests" {
//     // Allocator for the String
//     const page_allocator = std.heap.page_allocator;
//     var arena = std.heap.ArenaAllocator.init(page_allocator);
//     defer arena.deinit();

//     // This is how we create the String
//     var myStr = String.init(arena.allocator());
//     defer myStr.deinit();

//     // allocate & capacity
//     try myStr.allocate(16);
//     assert(myStr.capacity() == 16);
//     assert(myStr.size == 0);

//     // truncate
//     try myStr.truncate();
//     assert(myStr.capacity() == myStr.size);
//     assert(myStr.capacity() == 0);

//     // concat
//     try myStr.concat("A");
//     try myStr.concat("\u{5360}");
//     try myStr.concat("💯");
//     try myStr.concat("Hello🔥");

//     assert(myStr.size == 17);

//     // pop & length
//     assert(myStr.len() == 9);
//     assert(eql(u8, myStr.pop().?, "🔥"));
//     assert(myStr.len() == 8);
//     assert(eql(u8, myStr.pop().?, "o"));
//     assert(myStr.len() == 7);

//     // str & cmp
//     assert(myStr.cmp("A\u{5360}💯Hell"));
//     assert(myStr.cmp(myStr.str()));

//     // charAt
//     assert(eql(u8, myStr.charAt(2).?, "💯"));
//     assert(eql(u8, myStr.charAt(1).?, "\u{5360}"));
//     assert(eql(u8, myStr.charAt(0).?, "A"));

//     // insert
//     try myStr.insert("🔥", 1);
//     assert(eql(u8, myStr.charAt(1).?, "🔥"));
//     assert(myStr.cmp("A🔥\u{5360}💯Hell"));

//     // find
//     assert(myStr.find("🔥").? == 1);
//     assert(myStr.find("💯").? == 3);
//     assert(myStr.find("Hell").? == 4);

//     // remove & removeRange
//     try myStr.removeRange(0, 3);
//     assert(myStr.cmp("💯Hell"));
//     try myStr.remove(myStr.len() - 1);
//     assert(myStr.cmp("💯Hel"));

//     const whitelist = [_]u8{ ' ', '\t', '\n', '\r' };

//     // trimStart
//     try myStr.insert("      ", 0);
//     myStr.trimStart(whitelist[0..]);
//     assert(myStr.cmp("💯Hel"));

//     // trimEnd
//     _ = try myStr.concat("lo💯\n      ");
//     myStr.trimEnd(whitelist[0..]);
//     assert(myStr.cmp("💯Hello💯"));

//     // clone
//     var testStr = try myStr.clone();
//     defer testStr.deinit();
//     assert(testStr.cmp(myStr.str()));

//     // reverse
//     myStr.reverse();
//     assert(myStr.cmp("💯olleH💯"));
//     myStr.reverse();
//     assert(myStr.cmp("💯Hello💯"));

//     // repeat
//     try myStr.repeat(2);
//     assert(myStr.cmp("💯Hello💯💯Hello💯💯Hello💯"));

//     // isEmpty
//     assert(!myStr.isEmpty());

//     // split
//     assert(eql(u8, myStr.split("💯", 0).?, ""));
//     assert(eql(u8, myStr.split("💯", 1).?, "Hello"));
//     assert(eql(u8, myStr.split("💯", 2).?, ""));
//     assert(eql(u8, myStr.split("💯", 3).?, "Hello"));
//     assert(eql(u8, myStr.split("💯", 5).?, "Hello"));
//     assert(eql(u8, myStr.split("💯", 6).?, ""));

//     var splitStr = String.init(arena.allocator());
//     defer splitStr.deinit();

//     try splitStr.concat("variable='value'");
//     assert(eql(u8, splitStr.split("=", 0).?, "variable"));
//     assert(eql(u8, splitStr.split("=", 1).?, "'value'"));

//     // splitToString
//     var newSplit = try splitStr.splitToString("=", 0);
//     assert(newSplit != null);
//     defer newSplit.?.deinit();

//     assert(eql(u8, newSplit.?.str(), "variable"));

//     // toLowercase & toUppercase
//     myStr.toUppercase();
//     assert(myStr.cmp("💯HELLO💯💯HELLO💯💯HELLO💯"));
//     myStr.toLowercase();
//     assert(myStr.cmp("💯hello💯💯hello💯💯hello💯"));

//     // substr
//     var subStr = try myStr.substr(0, 7);
//     defer subStr.deinit();
//     assert(subStr.cmp("💯hello💯"));

//     // clear
//     myStr.clear();
//     assert(myStr.len() == 0);
//     assert(myStr.size == 0);

//     // writer
//     const writer = myStr.writer();
//     const length = try writer.write("This is a Test!");
//     assert(length == 15);

//     // owned
//     const mySlice = try myStr.toOwned();
//     assert(eql(u8, mySlice.?, "This is a Test!"));
//     arena.allocator().free(mySlice.?);

//     // StringIterator
//     var i: usize = 0;
//     var iter = myStr.iterator();
//     while (iter.next()) |ch| {
//         if (i == 0) {
//             assert(eql(u8, "T", ch));
//         }
//         i += 1;
//     }

//     assert(i == myStr.len());
// }

// test "init with contents" {
//     // Allocator for the String
//     const page_allocator = std.heap.page_allocator;
//     var arena = std.heap.ArenaAllocator.init(page_allocator);
//     defer arena.deinit();

//     var initial_contents = "String with initial contents!";

//     // This is how we create the String with contents at the start
//     var myStr = try String.init_with_contents(arena.allocator(), initial_contents);
//     assert(eql(u8, myStr.str(), initial_contents));
// }
