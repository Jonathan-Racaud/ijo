using System;

namespace ijo
{
	class Disassembler
	{
		let padding = "    ";

		public void DisassembleChunk(ref Chunk chunk, StringView name)
		{
			Console.WriteLine(scope $"== {name} ==");
			Console.WriteLine(scope $"[offset] [line]\t[op code]\t[byte]\t[value]");

			for (var offset = 0; offset < chunk.Count;)
			{
				offset = DisassembleInstruction(ref chunk, offset);
			}
		}

		int DisassembleInstruction(ref Chunk chunk, int offset)
		{
			Console.Write(scope $"{offset:D4}    ");

			if (offset > 0 && chunk.Lines[offset] == chunk.Lines[offset - 1])
			{
				Console.Write("    |");
			}
			else
			{
				Console.Write(scope $" {chunk.Lines[offset]:D4}");
			}

			OpCode instruction = chunk.Code[offset];

			switch (instruction)
			{
			case .Constant: return ConstantInstruction(ref chunk, instruction, offset);
			case .Exit: return SimpleInstruction(instruction, offset);
			default: return ErrorInstruction(instruction, offset);
			}
		}

		int ConstantInstruction(ref Chunk chunk, OpCode code, int offset)
		{
			let constant = chunk.Code[offset + 1];
			Console.Write(scope $"\t{code}\t{(uint)code}\t'");
			chunk.Constants.Values[constant].Print();
			Console.WriteLine("'");

			return offset + 2;
		}

		int SimpleInstruction(OpCode code, int offset)
		{
			Console.WriteLine(scope $"\t{code}");
			return offset + 1;
		}

		int ErrorInstruction(OpCode code, int offset)
		{
			Console.Error.WriteLine(scope $"Unknown op code: {offset:D4} {code:D4}");
			return offset + 1;
		}
	}
}