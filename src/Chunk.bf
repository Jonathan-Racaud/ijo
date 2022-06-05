using System;
using System.Collections;

namespace ijo
{
    /// Represents a series of instructions as a dynamic array
    struct Chunk : IDisposable
    {
        public int Count => Code.Count;
        public int Capacity => Code.Capacity;
        public List<uint8> Code { get; private set mut; } = new .();
        public ValueArray Constants = .();

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

        public void Dispose()
        {
            delete Code;
            delete Lines;
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
    }
}