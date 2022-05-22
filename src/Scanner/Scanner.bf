using System;
using System.IO;
using System.Collections;

using ijo.Mixins;

namespace ijo.Scanner
{
	class Scanner
	{
		private StreamReader sr ~ delete _;
		private List<Token> tokens = new .() ~ DeleteContainerAndDisposeItems!(_);
		private int tokenStart = 0;
		private int currentChar = 0;
		private int line = 1;

		private Dictionary<StringView, TokenType> keywords = new .() {
			("and", .And),
			("type", .Type),
			("else", .Else),
			("false", .False),
			("func", .Func),
			("functions", .Functions),
			("interface", .Functions),
			("operators", .Functions),
			("for", .For),
			("if", .If),
			("nil", .Nil),
			("or", .Or),
			("of", .Of),
			("return", .Return),
			("base", .Base),
			("this", .This),
			("true", .True),
			("var", .Var),
			("let", .Var),
			("while", .While),
			("assume", .Assume)
		} ~ delete _;

		public this(Stream stream)
		{
			sr = new StreamReader(stream);
		}

		public Result<List<Token>, ScanError> ScanTokens()
		{
			while (!sr.EndOfStream)
			{
				tokenStart = currentChar;
				Guard!(ScanToken(),
					(Otherwise) scope () => {
						ijoRuntime.PrintError(line, currentChar, ScanError.Unknown);
					});
			}

			return .Ok(tokens);
		}

		Result<void, ScanError> ScanToken()
		{
			let c = Unwrap!(sr.Read());

			switch (c)
			{
			case '(': AddToken(.LeftParen);
			case ')': AddToken(.RightParen);
			case '{': AddToken(.LeftBrace);
			case '}': AddToken(.RightBrace);
			case ',': AddToken(.Comma);
			case '.': AddToken(.Dot);
			case '-': AddToken(.Minus);
			case '+': AddToken(.Plus);
			case ';': AddToken(.Semicolon);
			case '*': AddToken(.Star);
			case ':': AddToken(.Colon);
			case '!': AddToken(Match('=') ? .BangEqual : .Bang);
			case '=': AddToken(Match('=') ? .EqualEqual: .Equal);
			case '<': AddToken(Match('=') ? .LessEqual : .Less);
			case '>': AddToken(Match('=') ? .GreaterEqual: .GreaterEqual);
			case '/': AddToken(.Slash);
			case '#': repeat { sr.Read(); } while (sr.Peek() != '\n' && !sr.EndOfStream);
			case ' ', '\r', '\t': break;
			case '\n': line++;
			case '"': ScanString();
			default:
				if (c.IsDigit)
					ScanNumber(c);
				else if (c.IsLetter || c == '_')
					ScanIdentifier(c);
				else
					return .Err(.UnexpectedCharacter);
			}

			return .Ok;
		}

		void AddToken(TokenType type)
		{
			tokens.Add(Token(type, type, line, currentChar));
		}

		void AddToken<T>(TokenType type, T value)
		{
			var token = Token(type, scope $"{value}", line, currentChar);
			token.SetLiteralValue(value);

			tokens.Add(token);
		}

		Result<void, ScanError> ScanString()
		{
			char8 char;
			let str = scope String();

			repeat
			{
				char = Unwrap!(sr.Read());

				if (char == '\n')
					line++;

				str.Append(char);
			} while (char != '"' && !sr.EndOfStream);
			str.RemoveFromEnd(1);

			if (sr.EndOfStream)
				return .Err(.NonTerminatedString);

			AddToken(.String, str);

			return .Ok;
		}	

		Result<void, ScanError> ScanNumber(char8 c)
		{
			let str = scope String();
			str.Append(c);

			while (Peek().IsDigit)
				str.Append(Read());

			if (!Peek().IsWhiteSpace && Peek() != '.' && Peek() != ';')
				return .Err(.NumberParsingError);

			if (Peek().IsWhiteSpace || Peek() == ';')
			{
				AddToken(.Integer, Unwrap!(int.Parse(str)));
			}
			else if (Peek() == '.' && PeekNext().IsDigit)
			{
				str.Append(Read());

				while (Peek().IsDigit)
					str.Append(Read());

				AddToken(.Double, Unwrap!(double.Parse(str)));
			}

			return .Ok;
		}

		Result<void, ScanError> ScanIdentifier(char8 c)
		{
			let str = scope String();
			str.Append(c);

			while (Peek().IsLetterOrDigit)
				str.Append(Read());

			TokenType type;

			if (!keywords.TryGetValue(str, out type))
				type = .Identifier;

			AddToken(type, str);
			return .Ok;
		}

		bool IsAtEnd()
			=> sr.EndOfStream;

		char8 Read()
			=> Unwrap!(sr.Read());

		char8 Peek()
			=> Unwrap!(sr.Peek());

		char8 PeekPrevious()
		{
			sr.BaseStream.Seek(sr.BaseStream.Position - 1);

			if (sr.EndOfStream)
				return '\0';

			let char = sr.Peek();

			sr.BaseStream.Seek(sr.BaseStream.Position + 1);

			return char;
		}

		char8 PeekNext()
		{
			sr.BaseStream.Seek(sr.BaseStream.Position + 1);

			if (sr.EndOfStream)
				return '\0';

			let char = sr.Peek();

			sr.BaseStream.Seek(sr.BaseStream.Position - 1);

			return char;
		}

		bool Match(char8 char)
		{
			if (sr.EndOfStream)
				return false;

			if (sr.Peek() == char)
			{
				sr.BaseStream.Position += 1;
				return true;
			}

			return false;
		}
	}
}