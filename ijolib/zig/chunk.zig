const std = @import("std");
const Value = @import("value").Value;

const OpCode = enum { Constant, Add, Sub, Mul, Div, Mod, Neg, Equal, NotEqual, LessThan, LessEqual, GreaterThan, GreaterEqual, True, False, Success, Error, Not, Print, PrintLn, Jump, JumpIfFalse, JumpBack, Module, GetLocal, SetLocal, Pop, Return };
const Chunk = struct {
    code: std.ArrayList(u32),
    lines: std.ArrayList(u32),
    constants: std.ArrayList(Value),

    fn add(self: *Chunk, instruction: u32) void {
        self.code.append(instruction);
    }

    fn add(self: *Chunk, first: u32, second: u32) void {
        self.code.append(first);
        self.code.append(second);
    }

    fn add(self: *Chunk, other: *Chunk) void {
        for (other.code) |instruction| {
            self.code.add(instruction);
        }
    }
};
