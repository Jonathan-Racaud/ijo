using System;

namespace ijo
{
	class Program
	{
		public static int Main(String[] args)
		{
			let vm = scope ijoVM();

			var chunk = Chunk();
			defer chunk.Dispose();

			for (var i = 0; i < 255; i++) {
				chunk.WriteConstant(10, i);
			}

			chunk.WriteConstant(42.69, 256);
			chunk.Write(OpCode.Exit, 256);

			let disassembler = scope Disassembler();
			disassembler.DisassembleChunk(ref chunk, "Test chunk");

			return 0;
		}
	}
}