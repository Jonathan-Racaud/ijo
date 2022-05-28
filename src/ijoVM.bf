using System;
namespace ijo
{
	class ijoVM
	{
		private Chunk chunk;
		private uint8* ip;

		public InterpretResult Interpret(Chunk chunk)
		{
			this.chunk = chunk;
			this.ip = chunk.Code.Ptr;

			return Run();
		}

		InterpretResult Run()
		{
			while(true)
			{
				let instruction = ReadByte();

				switch ((OpCode)instruction)
				{
				case .Constant, .ConstantLong: HandleConstant!(instruction);
				case .Exit: return .Ok;
				}
			}
		}

		mixin HandleConstant(OpCode type)
		{
			switch (ReadConstant(type))
			{
			case .Ok(let val):
				PrintValue(val);
				Console.WriteLine();
			case .Err(let err): return err;
			}
		}

		uint8 ReadByte() => (*ip++);

		Result<int, InterpretResult> ReadConstant(OpCode type)
		{
			if (type == .Constant)
			{
				return ReadByte();
			}
			else if (type == .ConstantLong)
			{
				uint8[4] bytes = .(
					ReadByte(),
					ReadByte(),
					ReadByte(),
					ReadByte()
				);
				let constant = ((int)bytes[0] << 24) + ((int)bytes[1] << 16) + ((int)bytes[2] << 8) + ((int)bytes[3]);

				return constant;
			}
			else
			{
				return .Err(.CompileError);
			}
		}

		void PrintValue(int index)
		{
			Console.Write(scope $"{chunk.Constants.Values[index]}");
		}
	}

	enum InterpretResult
	{
		Ok,
		CompileError,
		RuntimeError
	}
}