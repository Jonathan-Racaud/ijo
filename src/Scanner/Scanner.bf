using System;
using System.IO;
using System.Collections;

using ijo.Mixins;

namespace ijo.Scanner
{
	class Scanner
	{
		private StringView source;
		private List<Token> tokens;
		private int tokenStart = 0;
		private int currentChar = 0;
		private int lineNumber = 1;

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

		public this(String string)
		{
			source = string;
		}

		public Result<void, ScanError> ScanTokens(out List<Token> outTokens)
		{
			outTokens = new .();

			tokens = outTokens;
			Guard!(
				ScanTokens(),
				(Otherwise) scope () => {
					ijoRuntime.PrintError(lineNumber, currentChar, ScanError.Unknown);
				});

			return .Ok;
		}

		Result<void, ScanError> ScanTokens()
		{
			while (!IsAtEnd())
			{
				let c = Read();

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
				case '#': repeat { Read(); } while (Peek() != '\n');
				case ' ', '\r', '\t': break;
				case '\n': lineNumber++;
				case '"': ScanString();
				default:
					if (c.IsDigit)
						ScanNumber();
					else if (c.IsLetter || c == '_')
						ScanIdentifier();
					else
						return .Err(.UnexpectedCharacter);
				}
			}
			return .Ok;
		}

		void AddToken(TokenType type)
		{
			tokens.Add(Token(type, type, lineNumber, currentChar));
		}

		void AddToken(TokenType type, String value)
		{
			var token = Token(type, value, lineNumber, currentChar);
			token.SetLiteralValue(value);

			tokens.Add(token);
		}

		void AddToken(TokenType type, int value)
		{
			var token = Token(type, scope $"{value}", lineNumber, currentChar);
			token.SetLiteralValue(value);

			tokens.Add(token);
		}

		void AddToken(TokenType type, double value)
		{
			var token = Token(type, scope $"{value}", lineNumber, currentChar);
			token.SetLiteralValue(value);

			tokens.Add(token);
		}

		Result<void, ScanError> ScanString()
		{
			char8 char;
			let str = scope String();

			repeat
			{
				char = Read();

				if (char == '\n')
					return .Err(.NonTerminatedString);

				str.Append(char);
			} while (char != '"' && !IsAtEnd());
			str.RemoveFromEnd(1);

			if (IsAtEnd())
				return .Err(.NonTerminatedString);

			AddToken(.String, str);

			return .Ok;
		}	

		Result<void, ScanError> ScanNumber()
		{
			let str = scope String();
			str.Append(PeekPrevious());

			while (Peek().IsDigit)
				str.Append(Read());

			if (!Peek().IsWhiteSpace &&
				Peek() != '.' &&
				Peek() != ';' &&
				Peek() != ')' &&
				Peek() != ',' &&
				Peek() != '}' &&
				Peek() != ']')
				return .Err(.NumberParsingError);

			if (Peek() == '.' && PeekNext().IsDigit)
			{
				str.Append(Read());

				while (Peek().IsDigit)
					str.Append(Read());

				AddToken(.Double, Unwrap!(double.Parse(str)));
				return .Ok;
			}

			AddToken(.Integer, Unwrap!(int.Parse(str)));
			

			return .Ok;
		}

		Result<void, ScanError> ScanIdentifier()
		{
			let str = scope String();
			str.Append(PeekPrevious());

			while (Peek().IsLetterOrDigit)
				str.Append(Read());

			TokenType type;

			if (!keywords.TryGetValue(str, out type))
				type = .Identifier;

			AddToken(type, str);
			return .Ok;
		}

		bool IsAtEnd()
			=> currentChar == source.Length;

		char8 Read()
			=> source[currentChar++];

		char8 Peek()
			=> source[currentChar];

		char8 PeekPrevious()
			=> source[currentChar - 1];

		char8 PeekNext()
		{
			if (currentChar >= source.Length)
				return '\0';

			return source[currentChar + 1];
		}

		bool Match(char8 char)
		{
			if (Peek() == char)
			{
				Read();
				return true;
			}

			return false;
		}
	}
}