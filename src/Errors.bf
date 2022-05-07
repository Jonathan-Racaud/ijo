using System;

namespace BLox
{
	abstract class Error
	{
		public String Message { get; } = new .() ~ delete _;
		public Token Token { get; set; }

		public this(Token token, StringView message)
		{
			this.Token = token;
			this.Message.Set(message);
		}
	}

	class RuntimeError: Error
	{
		public this(Token token, StringView message): base(token, message)
		{
			this.Token = token;
			this.Message.Set(message);
		}
	}

	class CompileError: Error
	{
		public this(Token token, StringView message): base(token, message)
		{
			this.Token = token;
			this.Message.Set(message);
		}
	}
}