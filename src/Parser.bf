using System.Collections;
using System;

namespace BLox
{
	public class Parser
	{
		private List<Token> tokens;
		private int current = 0;

		public this(List<Token> tokens)
		{
			this.tokens = tokens;
		}

		public Result<void, ParseError> Parse(out Expr expr)
		{
			Guard!(
				Expression(out expr),
				(Action)scope [&]() => {
					delete expr;
					expr = null;
				}
			);

			return .Ok;
		}

		private Result<void, ParseError>  Expression(out Expr expr)
		{
			return Equality(out expr);
		}

		private Result<void, ParseError>  Equality(out Expr expr)
		{
			Guard!(Comparison(out expr));

			while (Match(.BANG_EQUAL, .EQUAL_EQUAL))
			{
				let op = Previous();
				Expr right;
				Guard!(Comparison(out right));
				expr = new Binary(expr, op, right);
			}

			return .Ok;
		}

		private Result<void, ParseError>  Comparison(out Expr expr)
		{
			Guard!(Term(out expr));

			while (Match(.GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL))
			{
				let op = Previous();
				Expr right;
				Guard!(Term(out right));
				expr = new Binary(expr, op, right);
			}

			return .Ok;
		}

		private Result<void, ParseError> Term(out Expr expr)
		{
			Guard!(Factor(out expr));

			while (Match(.MINUS, .PLUS))
			{
				let op = Previous();
				Expr right;
				Guard!(Factor(out right));
				expr = new Binary(expr, op, right);
			}

			return .Ok;
		}

		private Result<void, ParseError> Factor(out Expr expr)
		{
			Guard!(UnaryRule(out expr));

			while (Match(.SLASH, .STAR))
			{
				let op = Previous();
				Expr right;
				Guard!(UnaryRule(out right));
				expr = new Binary(expr, op, right);
			}

			return .Ok;
		}

		private Result<void, ParseError> UnaryRule(out Expr expr)
		{
			if (Match(.BANG, .MINUS))
			{
				let op = Previous();
				Expr right;
				Guard!(UnaryRule(out right), (Action)scope [&]() => {expr = null;});
				expr = new Unary(op, right);
				return .Ok;
			}

			Guard!(Primary(out expr));

			return .Ok;
		}

		private Result<void, ParseError> Primary(out Expr expr)
		{
			if (Match(.TRUE)) {
				expr = new Literal(Variant.Create(true));
				return .Ok;
			}

			if (Match(.FALSE)) {
				expr = new Literal(Variant.Create(false));
				return .Ok;
			}

			if (Match(.NIL)) {
				expr = new Literal(Variant.Create<Object>(null));
				return .Ok;
			}

			if (Match(.NUMBER, .STRING)) {
				expr = new Literal(Previous().literal);
				return .Ok;
			}

			if (Match(.LEFT_PAREN))
			{
				Guard!(Expression(out expr));
				Guard!(Consume(.RIGHT_PAREN, "Expect ')' after expression"));
				expr = new Grouping(expr);
				return .Ok;
			}

			expr = null;
			return .Err(Error(Peek(), .ExpectedExpression, "Expected expression."));
		}
		 
		private Result<Token, ParseError> Consume(TokenType endToken, StringView errorMessage)
		{
			if (IsExpected(endToken)) return Advance();

			return .Err(Error(Peek(), .MissingExpectedToken, errorMessage));
		}

		private ParseError Error(Token token, ParseError error, StringView message)
		{
			Lox.Error(token, message);

			return error;
		}

		private void Synchronize()
		{
			Advance();

			while (!IsAtEnd())
			{
				if (Previous().type == .SEMICOLON) return;

				switch (Peek().type)
				{
				case .CLASS, .FUN, .VAR, .FOR, .IF, .WHILE, .PRINT, .RETURN: return;
				default: break;
				}

				Advance();
			}
		}

		private bool Match(params TokenType[] tokenTypes)
		{
			for (let type in tokenTypes)
			{
				if (IsExpected(type))
				{
					Advance();
					return true;
				}
			}

			return false;
		}

		private bool IsExpected(TokenType type)
		{
			if (IsAtEnd()) return false;

			return Peek().type == type;
		}

		private Token Advance()
		{
			if (!IsAtEnd()) current++;

			return Previous();
		}
		private Token Previous() => tokens[current - 1];
		private Token Peek() => tokens[current];
		private bool IsAtEnd() => Peek().type == .EOF;
	}
}