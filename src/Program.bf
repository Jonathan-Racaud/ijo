using System;

namespace ijo
{
	class Program
	{
		public static int Main(String[] args)
		{
			var chunk = Chunk();
			defer chunk.Dispose();

			chunk.Write(OpCode.Exit);

			let disassembler = scope Disassembler();
			disassembler.DisassembleChunk(ref chunk, "Test chunk");

			return 0;
		}
	}
}