const std = @import("std");
const Scanner = struct {
    start: *u8,
    current: *u8,
    line: u32,

    fn init(self: *Scanner, source: []const u8) void {
        self.start = source;
        self.current = source;
        self.line = 1;
    }

    fn scan(self: *Scanner) void {
        self.skipWhitespace();
    }
};

fn skipWhitespace(self: *Scanner) void {
    while (true) {
        const c = self.peek();

        switch (c) {
            ' ', '\r', '\t' => {
                self.advance();
            },
            '/' => {
                if (self.peekNext() == '/') {
                    while (self.peek() != '\n' and !self.isAtEnd()) {
                        self.advance();
                    }
                } else {
                    return;
                }
            },
            else => {},
        }
    }
}

fn peek(self: *Scanner) u8 {
    return self.current.*;
}

fn peekNext(self: *Scanner) u8 {
    if (!self.isAtEnd()) {
        return '\0';
    }

    return self.current[1];
}

fn advance(self: *Scanner) u8 {
    self.current += 1;
    return self.current[-1];
}

fn isAtEnd(self: *Scanner) bool {
    return self.current.* = '\0';
}
