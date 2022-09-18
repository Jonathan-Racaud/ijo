using System;
using System.Collections;
namespace ijo;

class ByteCodePrinter
{
    Scope Scope;

    public this(Scope env)
    {
        Scope = env;
    }

    public void Print(List<uint16> code)
    {
        for (var i = 0; i < code.Count; i++)
        {
            let op = (OpCode)code[i];

            switch (op)
            {
            case .ConstantD,.ConstantI: i += PrintConstant(code, op, i);
            case .String: i += PrintString(code, op, i);
            case .Symbol: i += PrintSymbol(code, op, i);
            case .IsTrue: i += PrintIsTrue(code, op, i);
            case
                .Add,
                .Subtract,
                .Modulo,
                .Divide,
                .Multiply,
                .Negate,
                .Opposite,
                .Not,
                .True,
                .False,
                .Equal,
                .NotEqual,
                .Greater,
                .GreaterThan,
                .Less,
                .LessThan,
                .Print,
                .Read,
                .VarDef,
                .Identifier,
                .Jump,
                .Return,
                .Break: PrintSimple(op);
            default:
                PrintError(op);
                return;
            }

            Console.WriteLine();
        }
    }

    // OP_CONST BYTE_NUM BYTE_1 BYTE_2 ... BYTE_N
    int PrintConstant(List<uint16> code, OpCode op, int index)
    {
        let argCount = code[index + 1];

        // For the moment we force only 1 byte for this operation
        // TODO: Handle multiple size bytes.
        Console.Write(scope $"{op.Str} {code[index + 2]}");

        return argCount + 1;
    }

    int PrintString(List<uint16> code, OpCode op, int index)
    {
        let idx = code[index + 1];

        Console.Write(scope $"{op.Str} {Scope.GetString(idx)}");

        return index + 1;
    }

    int PrintSymbol(List<uint16> code, OpCode op, int index)
    {
        let idx = code[index + 1];

        Console.Write(scope $"{op.Str} {Scope.GetSymbol(idx)}");

        return index + 1;
    }

    int PrintIsTrue(List<uint16> code, OpCode op, int index)
    {
        let trueIdx = code[index + 1];
        let falseIdx = code[index + 2];

        Console.Write(scope $"{op.Str} {trueIdx} {falseIdx}");

        return index + 2;
    }

    void PrintSimple(OpCode op)
    {
        Console.Write(op.Str);
    }

    void PrintError(OpCode op)
    {
        Console.WriteLine(scope $"[ERROR]: Unknown byte code: {op}");
    }
}