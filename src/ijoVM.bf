using System;
using System.Collections;
namespace ijo
{
    class ijoVM
    {
        private ijoCompiler compiler = new .() ~ delete _;

        private Chunk chunk;
        private uint8* ip;

        private List<ijoValue> stak = new .() ~ delete _;

        typealias BinaryOpDelegate = function ijoValue(ijoValue, ijoValue);

        public InterpretResult Interpret(StringView source)
        {
            switch (compiler.Compile(source))
            {
            case .Ok: break;
            case .Error: return .CompileError;
            }

            return .Ok;
        }

        InterpretResult Run()
        {
            while (true)
            {
#if DEBUG_TRACE_EXECUTION
                Console.Write("      ");
                for (let slot in stak)
                {
                    Console.Write("[");
                    PrintValue(slot);
                    Console.Write("]");
                }
                Console.WriteLine();
                Disassembler.DisassembleInstruction(ref chunk, (int)(ip - chunk.Code.Ptr));
#endif
                let instruction = ReadByte();

                switch ((OpCode)instruction)
                {
                case .Constant,.ConstantLong:
                    HandleConstant!(instruction);
                case .Negate:
                    stak.Add(-stak.PopFront());
                case .Add:
                    HandleBinaryOp((a, b) => a + b);
                case .Subtract:
                    HandleBinaryOp((a, b) => a - b);
                case .Multiply:
                    HandleBinaryOp((a, b) => a * b);
                case .Divide:
                    HandleBinaryOp((a, b) => a / b);
                case .Exit:
                    if (!stak.IsEmpty)
                        PrintLineValue(stak.PopFront());
                    return .Ok;
                }
            }
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

        void PrintValue(ijoValue value)
        {
            Console.Write(scope $"{value}");
        }

        void PrintLineValue(ijoValue value)
        {
            PrintValue(value);
            Console.WriteLine();
        }
    }

    enum InterpretResult
    {
        Ok,
        CompileError,
        RuntimeError
    }
}