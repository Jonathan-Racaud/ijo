using System;
using System.Collections;
using ijo.Types;

namespace ijo
{
    /// Represents a series of instructions as a dynamic array
    struct Chunk : IDisposable
    {
        public int Count => Code.Count;
        public int Capacity => Code.Capacity;
        public List<uint8> Code { get; private set mut; } = new .();
        public ValueArray Constants = .();
        public List<StringView> Symbols { get; private set mut; } = new .();
        public List<StringView> Strings { get; private set mut; } = new .();

        public List<int> Lines { get; private set mut; } = new .();

        public void Write(uint8 byte, int lineNumber) mut
        {
            Code.Add(byte);
            Lines.Add(lineNumber);
        }

        public int WriteConstant(ijoValue value, int lineNumber) mut
        {
            Constants.Add(value);

            if (Constants.Count > uint8.MaxValue)
            {
                Code.Add(OpCode.ConstantLong);

                for (var byte in IntToByteArray!(Constants.Count - 1))
                {
                    Code.Add(byte);
                }
            }
            else
            {
                Code.Add(OpCode.Constant);
                Code.Add((uint8)Constants.Count - 1);
            }
            Lines.Add(lineNumber);

            return Count - 1;
        }

        public void WriteInternString(StringView str)
        {
            let index = HandleInternString(str);

            if (index > uint8.MaxValue)
            {
                Code.Add(OpCode.InternStringLong);

                for (var byte in Int16ToByteArray!(index))
                {
                    Code.Add(byte);
                }
            }
            else
            {
                Code.Add(OpCode.InternString);
                Code.Add((uint8)index);
            }
        }

        public void WriteSymbol(StringView symbol)
        {
            let index = HandleSymbol(symbol);

            if (index > uint8.MaxValue)
            {
                Code.Add(OpCode.SymbolLong);

                for (var byte in Int16ToByteArray!(index))
                {
                    Code.Add(byte);
                }
            }
            else
            {
                Code.Add(OpCode.Symbol);
                Code.Add((uint8)index);
            }
        }

        uint16 HandleInternString(StringView str)
        {
            if (Strings.Contains(str))
                return (uint16)Strings.IndexOf(str);

            Strings.Add(str);
            return (uint16)Strings.Count - 1;
        }

        uint16 HandleSymbol(StringView str)
        {
            if (Symbols.Contains(str))
                return (uint16)Symbols.IndexOf(str);

            Symbols.Add(str);
            return (uint16)Symbols.Count - 1;
        }

        public void Dispose()
        {
            delete Code;
            delete Lines;
            delete Strings;
            delete Symbols;
            Constants.Dispose();
        }

        // Store as big-endian
        mixin IntToByteArray(int value)
        {
            uint8[4] bytes = .();

            bytes[0] = (uint8)(value >> 24) & 0xFF;
            bytes[1] = (uint8)(value >> 16) & 0xFF;
            bytes[2] = (uint8)(value >> 8) & 0xFF;
            bytes[3] = (uint8)value & 0xFF;

            bytes
        }

        mixin Int16ToByteArray(int value)
        {
            uint8[2] bytes = .();

            bytes[0] = (uint8)(value >> 24) & 0xFF;
            bytes[1] = (uint8)value & 0xFF;

            bytes
        }
    }
}