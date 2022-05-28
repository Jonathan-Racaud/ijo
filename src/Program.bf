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
				chunk.WriteConstant(i, i);
			}

			chunk.WriteConstant(42.69, 256);
			chunk.Write(OpCode.Exit, 256);

			vm.Interpret(chunk);

			return 0;
		}
	}
}