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
			Console.Write(scope $"{offset:D4} N/A");

			OpCode instruction = chunk.Code[offset];

			switch (instruction)
			{
			case .Constant, .ConstantLong: return ConstantInstruction(ref chunk, instruction, offset);
			case .Exit: return SimpleInstruction(instruction, offset);
			default: return ErrorInstruction(instruction, offset);
			}
		}

		int ConstantInstruction(ref Chunk chunk, OpCode code, int offset)
		{
			var byteNumber = 2;

			Console.Write(scope $"\t{code}\t{(uint)code}\t'");

			if (code == OpCode.ConstantLong)
			{
				// Stores as big-endian
				uint8[4] bytes = .(
					chunk.Code[offset + 1],
					chunk.Code[offset + 2],
					chunk.Code[offset + 3],
					chunk.Code[offset + 4]
				);
				let constant = ((int)bytes[0] << 24) + ((int)bytes[1] << 16) + ((int)bytes[2] << 8) + ((int)bytes[3]);

				chunk.Constants.Values[constant].Print();

				// offset is OpCode + 4 bytes for the value
				// so next OpCode is 5 bytes after current offset
				byteNumber = 5;
			}
			else
			{
				let constant = chunk.Code[offset + 1];
				chunk.Constants.Values[constant].Print();
			}

			Console.WriteLine("'");

			return offset + byteNumber;
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