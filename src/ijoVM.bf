using System;
using System.Collections;
namespace ijo
{
    class ijoVM
    {
        private ijoCompiler compiler = new .() ~ delete _;

        private Chunk* chunk;
        private uint8* ip;

        private List<ijoValue> stak = new .() ~ delete _;

        typealias BinaryOpDelegate = function ijoValue(ijoValue, ijoValue);

        public InterpretResult Interpret(String source)
        {
            Chunk compiledChunk;

            let compileResult = compiler.Compile(source, out compiledChunk);
            defer compiledChunk.Dispose();

            switch (compileResult)
            {
            case .Ok: break;
            case .Error: return .CompileError;
            }

            chunk = &compiledChunk;
            ip = chunk.Code.Ptr;

            return Run();
        }

        InterpretResult Run()
        {
#if DEBUG_TRACE_EXECUTION
            Console.Write("== Trace Execution ==");
            defer Console.WriteLine("== /Trace Execution ==");
#endif
            while (true)
            {
#if DEBUG_TRACE_EXECUTION
                Console.Write("      ");
                for (let slot in stak)
                {
                    Console.Write("[");
                    slot.Print();
                    Console.Write("]");
                }
                Console.WriteLine();
                Disassembler.DisassembleInstruction(chunk, (int)(ip - chunk.Code.Ptr));
#endif
                let instruction = ReadByte();

                switch ((OpCode)instruction)
                {
                case .Constant,.ConstantLong:
                    HandleConstant!(instruction);
                case .Nil:
                    stak.AddFront(ijoValue.Nil);
                case .True:
                    stak.AddFront(ijoValue.Bool(true));
                case .False:
                    stak.AddFront(ijoValue.Bool(false));
                case .Negate:
                    if (!Peek(0).IsNumber())
                    {
                        Console.Error.WriteLine("Expected a number");
                        return .RuntimeError;
                    }

                    let value = stak.PopFront().Double();
                    stak.AddFront(-value);
                case .Add:
                    if (!Peek(0).IsNumber() || !Peek(1).IsNumber())
                    {
                        Console.Error.WriteLine("Expected a number");
                        return .RuntimeError;
                    }
                    HandleBinaryOp((a, b) => a + b);
                case .Subtract:
                    if (!Peek(0).IsNumber() || !Peek(1).IsNumber())
                    {
                        Console.Error.WriteLine("Expected a number");
                        return .RuntimeError;
                    }
                    HandleBinaryOp((a, b) => a - b);
                case .Multiply:
                    if (!Peek(0).IsNumber() || !Peek(1).IsNumber())
                    {
                        Console.Error.WriteLine("Expected a number");
                        return .RuntimeError;
                    }
                    HandleBinaryOp((a, b) => a * b);
                case .Divide:
                    if (!Peek(0).IsNumber() || !Peek(1).IsNumber())
                    {
                        Console.Error.WriteLine("Expected a number");
                        return .RuntimeError;
                    }
                    HandleBinaryOp((a, b) => a / b);
                case .Modulo:
                    if (!Peek(0).IsNumber() || !Peek(1).IsNumber())
                    {
                        Console.Error.WriteLine("Expected a number");
                        return .RuntimeError;
                    }
                    HandleBinaryOp((a, b) => a % b);
                case .Return:
                    if (!stak.IsEmpty)
                        stak.PopFront().PrintLine();
                    return .Ok;
                default: return .Ok;
                }
            }
        }

        ijoValue Peek(int distance)
        {
            return *(stak.Ptr + distance);
        }

        mixin HandleConstant(OpCode type)
        {
            switch (ReadConstant(type))
            {
            case .Ok(let val):
                stak.AddFront(val);
            case .Err(let err): return err;
            }
        }

        void HandleBinaryOp(BinaryOpDelegate op)
        {
            // Because we want to have left to right operations
            // we have to pop on 'b' as it is first in the stack (being inserted second)
            // then we can pop 'a'.
            let b = stak.PopFront();
            let a = stak.PopFront();

            stak.AddFront(op(a, b));
        }

        uint8 ReadByte() => (*ip++);

        Result<ijoValue, InterpretResult> ReadConstant(OpCode type)
        {
            if (type == .Constant)
            {
                return chunk.Constants.Values[ReadByte()];
            }
            else if (type == .ConstantLong)
            {
                uint8[4] bytes = .(
                    ReadByte(),
                    ReadByte(),
                    ReadByte(),
                    ReadByte()
                    );
                let constant = ((int)bytes[0] << 24) + ((int)bytes[1] << 16) + ((int)bytes[2] << 8) + ((int)bytes[3]);

                return chunk.Constants.Values[constant];
            }
            else
            {
                return .Err(.CompileError);
            }
        }
    }

    enum InterpretResult
    {
        Ok,
        CompileError,
        RuntimeError
    }
}