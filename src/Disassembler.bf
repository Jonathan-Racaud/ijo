using System;

namespace ijo
{
	class Disassembler
	{
		public void DisassembleChunk(ref Chunk chunk, StringView name)
		{
			Console.WriteLine(scope $"== {name} ==");

			for (var offset = 0; offset < chunk.Count; offset++)
			{
				offset = DisassembleInstruction(ref chunk, offset);
			}
		}

		int DisassembleInstruction(ref Chunk chunk, int offset)
		{
			OpCode instruction = chunk.Code[offset];

			switch (instruction)
			{
			case .Exit: return SimpleInstruction(instruction, offset);
			default: return ErrorInstruction(instruction, offset);
			}
		}

		int SimpleInstruction(OpCode code, int offset)
		{
			WriteOpCode!(code);
			return offset + 1;
		}

		int ErrorInstruction(OpCode code, int offset)
		{
			Console.Error.WriteLine(scope $"Unknown op code: {code:D4}");
			return offset + 1;
		}

		mixin WriteOpCode(OpCode code)
		{
			Console.WriteLine(scope $"{(uint8)code:D4} {code}");
		}
	}
}