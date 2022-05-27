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
		public ValueArray Constants = .();

		public List<int> Lines { get; private set mut; } = new .(); 

		public void Write(uint8 byte, int lineNumber) mut {
			Code.Add(byte);
			Lines.Add(lineNumber);
		}

		public int AddConstant(ijoValue value)
		{
			Constants.Add(value);
			return Constants.Count - 1;
		}

		public void Dispose()
		{
			delete Code;
			delete Lines;
			Constants.Dispose();
		}
	}
}