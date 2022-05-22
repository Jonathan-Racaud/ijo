using System;
namespace ijo.Parser
{
	enum ParseError
	{
		case NoError;
		case MissingExpectedToken(Token);
		case ExpectedExpression(Token);
		case InvalidAssignmentTarget(Token);
		case ExpectedBlock(Token);

		case NotImplemented;
		case CannotUseLetVariable(Token token);

		public static operator StringView(Self value)
		{
			switch (value)
			{
			case .NoError: return "No Error";
			case .MissingExpectedToken(let token): return scope $"Missing expected token: {token.Lexeme}";
			case .ExpectedExpression(let token): return scope $"Expected expression near: {token.Lexeme}";
			case .InvalidAssignmentTarget(let token): return scope $"Invalid assignment target near: {token.Lexeme}";
			case .ExpectedBlock(let token): return scope $"Expected block near: {token.Lexeme}";
			case .CannotUseLetVariable(let token): return scope $"Cannot use 'let' here: {token.Lexeme}";
			case .NotImplemented: return "Not implemented";
			}
		}
	}
}