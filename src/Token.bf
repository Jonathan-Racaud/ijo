using System;
namespace BLox
{
	public class Token
	{
		public TokenType type;
		public String lexeme = new .() ~ delete _;
		public String stringLiteral = new .() ~ delete _;
		public Variant literal;
		public int line;

		public this(TokenType type, String lexeme, double literal, int line)
		{
			this.type = type;
			this.lexeme.Set(lexeme);
			this.line = line;

			this.literal = Variant.Create(literal);
		}

		public this(TokenType type, String lexeme, String literal, int line)
		{
			this.type = type;
			this.lexeme.Set(lexeme);
			this.line = line;

			stringLiteral.Set(literal);
			this.literal = Variant.Create(stringLiteral);
		}

		public this(TokenType type, String lexeme, Object literal, int line)
		{
			this.type = type;
			this.lexeme.Set(lexeme);
			this.line = line;

			this.literal = Variant.Create(literal);
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