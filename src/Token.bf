using System;
namespace ijo
{
	struct Token: IDisposable
	{
		public TokenType Type;
		public String Lexeme = new .();
		public Variant Literal { get; private set mut; } = default;
		public int Line;
		public int Column;

		public this(TokenType type, StringView lexeme, int line, int column)
		{
			Type = type;
			Lexeme.Set(lexeme);
			Line = line;
			Column = column;
		}

		public this(Token token)
		{
			Type = token.Type;
			Lexeme.Set(token.Lexeme);
			Line = token.Line;
			Column = token.Column;
		}

		public void SetLiteralValue(double value) mut
		{
			Literal = Variant.Create(value);
		}

		public void SetLiteralValue(int value) mut
		{
			Literal = Variant.Create(value);
		}

		public void SetLiteralValue(String obj) mut
		{
			Literal = Variant.Create(new String(obj), true);
		}

		public void SetLiteralValue(StringView obj) mut
		{
			Literal = Variant.Create(new String(obj), true);
		}

		/*public void SetLiteralValue(Object obj) mut
		{
			Literal = Variant.Create(obj);
		}*/

		public void Dispose() mut
		{
			if (Literal.OwnsMemory)
				Literal.Dispose();
			delete Lexeme;
		}
	}

	enum TokenType
	{
		// Single character tokens
		case LeftParen, RightParen, LeftBrace, RightBrace,
		Comma, Colon, Dot, Minus, Plus, Semicolon, Slash, Star,
		Pound,

		// One or two character tokens
		Bang, BangEqual,
		Equal, EqualEqual,
		Greater, GreaterEqual,
		Less, LessEqual,

		// Literals
		Identifier, String, Double, Integer,

		// Keywords
		Type, Functions, Interface, Operators,
		Func, Var, Let, Base, This,
		True, False, While, For,
		Nil, If, Else, And, Or, Assume,
		Return, Of, Import,

		EOF;

		public static operator StringView(Self value)
		{
			switch (value)
			{
			case .LeftParen: return "(";
			case .RightParen: return ")";
			case .LeftBrace: return "{";
			case .RightBrace: return "}";
			case .Comma: return ",";
			case .Dot: return ".";
			case .Minus: return "-";
			case .Plus: return "+";
			case .Semicolon: return ";";
			case .Colon: return ":";
			case .Slash: return "/";
			case .Pound: return "#";
			case .Star: return "*";
			case .Bang: return "!";
			case .BangEqual: return "!=";
			case .Equal: return "=";
			case .EqualEqual: return "==";
			case .Greater: return ">";
			case .GreaterEqual: return ">=";
			case .Less: return "<";
			case .LessEqual: return "<=";
			case .Type: return "type";
			case .Functions: return "functions";
			case .Interface: return "interface";
			case .Operators: return "operators";
			case .Func: return "func";
			case .Var: return "var";
			case .Let: return "let";
			case .Base: return "base";
			case .This: return "this";
			case .True: return "true";
			case .False: return "false";
			case .While: return "while";
			case .For: return "for";
			case .If: return "if";
			case .Else: return "else";
			case .Assume: return "assume";
			case .And: return "and";
			case .Or: return "or";
			case .Return: return "return";
			case .Of: return "of";
			case .Import: return "import";
			case .EOF: return "\0";
			default: return "";
			}
		}
	}
}