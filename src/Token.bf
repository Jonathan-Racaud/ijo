using System;
namespace BLox
{
	public class Token
	{
		private TokenType type;
		private String lexeme = new .() ~ delete _;
		private Variant literal ~ literal.Dispose();
		private int line;

		public this(TokenType type, String lexeme, Variant literal, int line)
		{
			this.type = type;
			this.lexeme.Set(lexeme);
			this.literal = literal;
			this.line = line;
		}

		public override void ToString(String outStr)
		{
			String lit = scope String();

			switch (literal.VariantType)
			{
			case typeof(String):
				lit.Set(literal.Get<String>());
			case typeof(Double):
				lit.Set(scope $"{literal.Get<Double>()}");
			}

			outStr.Clear();
			outStr.Set(scope $"{type} {lexeme} {lit}");
		}
	}
}