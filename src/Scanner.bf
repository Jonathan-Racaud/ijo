using System;
using System.Collections;
namespace BLox
{
	public class Scanner
	{
		private String source = new .() ~ delete _;
		private List<Token> tokens;
		private int start = 0;
		private int current = 0;
		private int line = 1;

		private Dictionary<StringView, TokenType> keywords = new .() {
			("and", .AND),
			("class", .CLASS),
			("else", .ELSE),
			("false", .FALSE),
			("fun", .FUN),
			("for", .FOR),
			("if", .IF),
			("nil", .NIL),
			("or", .OR),
			("print", .PRINT),
			("return", .RETURN),
			("super", .SUPER),
			("this", .THIS),
			("true", .TRUE),
			("var", .VAR),
			("while", .WHILE)
		} ~ delete _;

		public this(String source)
		{
			this.source.Set(source);
		}

		public void ScanTokens(out List<Token> outTokens)
		{
			outTokens = new .();
			tokens = outTokens;

			while (!IsAtEnd())
			{
				start = current;
				ScanToken();
			}

			tokens.Add(new Token(.EOF, "", (Object)null, line));
		}

		private void ScanToken()
		{
			let c = Advance();

			switch (c)
			{
			case '(': AddToken(.LEFT_PAREN);
			case ')': AddToken(.RIGHT_PAREN);
			case '{': AddToken(.LEFT_BRACE);
			case '}': AddToken(.RIGHT_BRACE);
			case ',': AddToken(.COMMA);
			case '.': AddToken(.DOT);
			case '-': AddToken(.MINUS);
			case '+': AddToken(.PLUS);
			case ';': AddToken(.SEMICOLON);
			case '*': AddToken(.STAR);
			case '!': AddToken(Match('=') ? .BANG_EQUAL : .BANG);
			case '=': AddToken(Match('=') ? .EQUAL_EQUAL : .EQUAL);
			case '<': AddToken(Match('=') ? .LESS_EQUAL : .LESS);
			case '>': AddToken(Match('=') ? .GREATER_EQUAL : .GREATER);
			case '/':
				if (Match('/'))
				{
					while (Peek() != '\n' && !IsAtEnd()) Advance();
				}
				else
				{
					AddToken(.SLASH);
				}
			case ' ', '\r', '\t': break;
			case '\n':
				line++;
				break;
			case '"': ParseString();
			default:
				if (c.IsDigit)
				{
					ParseNumber();
				}
				else if (c.IsLetter || c == '_')
				{
					ParseIdentifier();
				}
				else
				{
					Lox.Error(line, "Unexpected character.");
				}
			}
		}

		private void AddToken(TokenType type) => AddToken(type, (Object)null);
		private void AddToken(TokenType type, String literal)
		{
			let text = scope String(source.Substring(start, current - start));
			tokens.Add(new Token(type, text, literal, line));
		}

		private void AddToken(TokenType type, double literal)
		{
			let text = scope String(source.Substring(start, current - start));
			tokens.Add(new Token(type, text, literal, line));
		}

		private void AddToken(TokenType type, Object literal)
		{
			let text = scope String(source.Substring(start, current - start));
			tokens.Add(new Token(type, text, literal, line));
		}

		private char8 Advance() => source[current++];

		private char8 Peek()
		{
			if (IsAtEnd())
				return '\0';

			return source[current];
		}

		private char8 PeekNext()
		{
			if (current + 1 > source.Length)
				return '\0';

			return source[current + 1];
		}

		private bool Match(char8 expected)
		{
			if (IsAtEnd())
				return false;

			if (source[current] != expected)
				return false;

			current++;
			return true;
		}

		private bool IsAtEnd() => current == source.Length;

		private void ParseString()
		{
			while(Peek() != '"' && !IsAtEnd())
			{
				if (Peek() == '\n')
					line++;
				Advance();
			}

			if (IsAtEnd())
			{
				Lox.Error(line, "Non-terminated string");
				return;
			}

			// The closing "
			Advance();

			let value = scope String(source.Substring(start + 1, current - start - 2));
			AddToken(.STRING, value);
		}

		private void ParseNumber()
		{
			while (Peek().IsDigit)
				Advance();

			if (Peek() == '.' && PeekNext().IsDigit)
			{
				Advance();

				while (Peek().IsDigit)
					Advance();
			}

			if (Double.Parse(source.Substring(start, current - start)) case .Ok(let number))
				AddToken(.NUMBER, number);
			else
				Lox.Error(line, "Couldn't parse number");
		}

		private void ParseIdentifier()
		{
			while (Peek().IsLetterOrDigit)
				Advance();

			let text = scope String(source.Substring(start, current - start));
			TokenType type;

			if (!keywords.TryGetValue(text, out type))
				type = .IDENTIFIER;

			AddToken(type);
		}
	}
}