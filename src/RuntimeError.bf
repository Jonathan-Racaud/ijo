using System;
using static System.Runtime;

namespace BLox
{
	class RuntimeError: Error
	{
		public String Message { get; } = new .() ~ delete _;
		public Token Token { get; set; }

		public this(Token token, StringView message)
		{
			this.Token = token;
			this.Message.Set(message);
		}
	}
}