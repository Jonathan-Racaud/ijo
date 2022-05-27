using System;

namespace ijo
{
	class Program
	{
		public static int Main(String[] args)
		{
			var chunk = Chunk();
			defer chunk.Dispose();

			let constant = chunk.AddConstant(1.2);
			chunk.Write(OpCode.Constant, 123);
			chunk.Write((uint8)constant, 123);

			chunk.Write(OpCode.Exit, 123);

			let disassembler = scope Disassembler();
			disassembler.DisassembleChunk(ref chunk, "Test chunk");

			return 0;
		}
	}
}