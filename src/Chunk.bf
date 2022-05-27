using System;
using System.Collections;

namespace ijo
{
	/// Represents a series of instructions as a dynamic array
	struct Chunk: IDisposable
	{
		public int Count => Code.Count;
		public int Capacity => Code.Capacity;
		public List<uint8> Code { get; private set mut; } = new .();

		public void Write(uint8 byte) mut {
			Code.Add(byte);
		}

		public void Dispose()
		{
			delete Code;
		}
	}
}