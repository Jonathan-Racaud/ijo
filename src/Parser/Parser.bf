using System;
using System.Collections;
using ijo.Expr;
using ijo.Mixins;
using ijo.Stmt;

namespace ijo.Parser
{
	typealias StmtResult = Result<Stmt, ParseError>;
	typealias StmtListResult = Result<List<Stmt>, ParseError>;
	typealias ExprResult = Result<Expr, ParseError>;
	typealias TokenResult = Result<Token, ParseError>;

	class Parser
	{
		private List<Token> tokens;
		private int current = 0;

		public this(List<Token> tokens)
		{
			this.tokens = tokens;
		}

		public StmtListResult Parse()
		{
			let statements = new List<Stmt>();

			while (!IsAtEnd())
			{
				let stmt = Unwrap!(ParseDeclaration());
				statements.Add(stmt);
			}

			return .Ok(statements);
		}

		StmtResult ParseDeclaration()
		{
			if (Match(.Var, .Let))
			{
				// Do we want to return here when we synchronize or not?
				let stmt = Unwrap!(
					ParseVarDeclaration(),
					(Otherwise) scope () => SynchronizeState());
				return stmt;
			}

			return ParseStatement();
		}

		StmtResult ParseVarDeclaration()
		{
			// We keep wether we declare a var or a let variable
			let mutability = Previous();
			let name = Guard!(Consume(.Identifier));

			Expr initializer = null;

			if (Match(.Equal))
			{
				initializer = ParseExpression();
			}

			Guard!(Consume(.Semicolon));

			return new VarStmt(mutability, name, initializer);
		}

		StmtResult ParseStatement()
		{
			if (Match(.If))
				return Guard!(ParseIfStatement());

			if (Match(.While))
				return Guard!(ParseWhileStatement());

			if (Match(.For))
				return Guard!(ParseForStatement());

			if (Match(.LeftBrace))
				return Guard!(ParseBlockStatement());

			return Guard!(ParseExpressionStatement());
		}

		StmtResult ParseIfStatement()
		{
			Guard!(Consume(.LeftParen));
			let condition = Guard!(ParseExpression());
			Guard!(Consume(.RightParen));

			if (!Match(.LeftBrace))
				return .Err(.ExpectedBlock(Previous()));
			let thenBranch = Guard!(ParseBlockStatement());

			Stmt elseBranch = null;
			if (Match(.Else))
			{
				if (!IsTokenMatching(.LeftBrace))
					return .Err(.ExpectedBlock(Previous()));

				elseBranch = Guard!(ParseBlockStatement());
			}

			return new IfStmt(condition, thenBranch, elseBranch);
		}

		StmtResult ParseWhileStatement()
		{
			Guard!(Consume(.LeftParen));
			let condition = Guard!(ParseExpression());
			Guard!(Consume(.RightParen));

			if (!Match(.LeftBrace))
				return .Err(.ExpectedBlock(Previous()));
			let body = Guard!(ParseBlockStatement());

			return new WhileStmt(condition, body);
		}

		StmtResult ParseForStatement()
		{
			Guard!(Consume(.LeftParen));

			Stmt initializer;
			if (Match(.Let))
				return .Err(.CannotUseLetVariable(Peek()));

			if (Match(.Semicolon))
				initializer = null;
			else if (Match(.Var))
				initializer = Guard!(ParseVarDeclaration());
			else
				initializer = Guard!(ParseStatement());

			Expr condition = null;
			if (!IsTokenMatching(.Semicolon))
				condition = Guard!(ParseExpression());
			Guard!(Consume(.Semicolon));

			Expr increment = null;
			if (!IsTokenMatching(.RightParen))
				condition = Guard!(ParseExpression());
			Guard!(Consume(.RightParen));

			if (!Match(.LeftBrace))
				return .Err(.ExpectedBlock(Peek()));
			var body = Guard!(ParseBlockStatement());

			if (increment != null)
			{
				body = new BlockStmt(new List<Stmt>() {
					body,
					new ExpressionStmt(increment)
				});
			}

			if (condition == null)
				condition = new LiteralExpr(Variant.Create(true));

			body = new WhileStmt(condition, body);

			if (initializer != null)
				body = new BlockStmt(new List<Stmt>() {
					initializer,
					body
				});

			return body;
		}

		StmtResult ParseBlockStatement()
 		{
			 var statements = new List<Stmt>();

			 while (!IsTokenMatching(.RightBrace) && !IsAtEnd())
			 {
				 let statement = Guard!(ParseDeclaration());

				 statements.Add(statement);
			 }

			 Guard!(
				 Consume(.RightBrace),
				 (Otherwise) scope [&]() => DeleteAndNullify!(statements));

			 return new BlockStmt(statements);
		}

		StmtResult ParseExpressionStatement()
		{
			var expr = Guard!(ParseExpression());

			Guard!(
				Consume(.Semicolon),
				(Otherwise) scope [&]() => DeleteAndNullify!(expr));

			return new ExpressionStmt(expr);
		}

		ExprResult ParseExpression()
		{
			return ParseAssignment();
		}

		ExprResult ParseAssignment()
		{
			var expr = Guard!(ParseOr());

			if (Match(.Equal))
			{
				let equal = Previous();
				let value = Guard!(ParseAssignment());

				if (expr is VariableExpr)
				{
					defer delete expr;

					let name = ((VariableExpr)expr).name;
					return new AssignmentExpr(name, value);
				}

				return .Err(.InvalidAssignmentTarget(equal));
			}
			return expr;
		}

		ExprResult ParseOr()
		{
			var expr = Guard!(ParseAnd());

			while (Match(.Or))
			{
				let op = Previous();
				let right = Guard!(ParseAnd());

				expr = new LogicalExpr(expr, op, right);
			}

			return expr;
		}

		ExprResult ParseAnd()
		{
			var expr = Guard!(ParseEquality());

			while (Match(.And))
			{
				let op = Previous();
				let right = Guard!(ParseEquality());

				expr = new LogicalExpr(expr, op, right);
			}

			return expr;
		}

		ExprResult ParseEquality()
		{
			var expr = Guard!(ParseComparison());

			while (Match(.BangEqual, .EqualEqual))
			{
				let op = Previous();
				let right = Guard!(ParseComparison());

				expr = new BinaryExpr(expr, op, right);
			}

			return expr;
		}

		ExprResult ParseComparison()
		{
			var term = Guard!(ParseTerm());

			while (Match(.Greater, .GreaterEqual, .Less, .LessEqual))
			{
				let op = Previous();
				let right = Guard!(ParseTerm());

				term = new BinaryExpr(term, op, right);
			}

			return term;
		}

		ExprResult ParseTerm()
		{
			var factor = Guard!(ParseFactor());

			while (Match(.Minus, .Plus))
			{
				let op = Previous();
				let right = Guard!(ParseFactor());

				factor = new BinaryExpr(factor, op, right);
			}

			return factor;
		}

		ExprResult ParseFactor()
		{
			var unary = Guard!(ParseUnary());

			while (Match(.Slash, .Star))
			{
				let op = Previous();
				let right = Guard!(ParseUnary());

				unary = new BinaryExpr(unary, op, right);
			}

			return unary;
		}

		ExprResult ParseUnary()
		{
			if (Match(.Bang, .Minus))
			{
				let op = Previous();
				let right = Guard!(ParseUnary());

				return new UnaryExpr(op, right);
			}

			return Guard!(ParseCall());
		}

		ExprResult ParseCall()
		{
			var expr = Guard!(ParsePrimary());

			// We handle it like this instead of while(Match(.LeftParen)) because
			// of how we'll handle properties on Objects.
			while (true)
			{
				if (Match(.LeftParen))
				{
					expr = FinishCall(expr);
				}
				else
				{
					break;
				}
			}

			return expr;
		}

		// Parse the call expression using the previously parsed expression as the callee
		ExprResult FinishCall(Expr expr)
		{
			let arguments = new List<Expr>();

			if (!IsTokenMatching(.RightParen))
			{
				repeat
				{
					if (arguments.Count >= 255)
					{
						ijoRuntime.PrintError("Cannot have more than 255 arguments.");
					}
					arguments.Add(Guard!(ParseExpression()));
				} while (Match(.Comma));
			}

			let paren = Guard!(Consume(.RightParen));

			return new CallExpr(expr, paren, arguments);
		}

		ExprResult ParsePrimary()
		{
			if (Match(.True))
				return new LiteralExpr(Variant.Create(true));

			if (Match(.False))
				return new LiteralExpr(Variant.Create(false));

			if (Match(.Integer, .Double, .String))
				return new LiteralExpr(Previous().Literal);

			if (Match(.LeftParen))
			{
				let expr = Guard!(ParseExpression());
				Guard!(Consume(.RightParen));
				return new GroupingExpr(expr);
			}

			if (Match(.Identifier))
				return new VariableExpr(Previous());

			return .Err(.ExpectedExpression(Peek()));
		}

		TokenResult Consume(TokenType type)
		{
			if (IsTokenMatching(type)) return Read();

			return .Err(.MissingExpectedToken(Peek()));
		}

		Token Read()
		{
			if (!IsAtEnd())
				current++;

			return Previous();
		}

		Token Previous()
			=> tokens[current - 1];
		Token Peek()
			=> tokens[current];

		bool IsAtEnd()
			=> (current == tokens.Count || Peek().Type == .EOF);

		bool Match(params TokenType[] tokenTypes)
		{
			for (let type in tokenTypes)
			{
				if (IsTokenMatching(type))
				{
					Read();
					return true;
				}
			}

			return false;
		}

		bool IsTokenMatching(TokenType type)
		{
			if (IsAtEnd())
				return false;

			return Peek().Type == type;
		}

		void SynchronizeState()
		{
			Read();

			while (!IsAtEnd())
			{
				if (Previous().Type case .Semicolon)
					return;

				switch (Peek().Type)
				{
				case .Type, .Func, .Functions, .Operators, .Interface,
					 .Var, .Let, .For, .If, .While, .Return:
					return;
				default:
					break;
				}

				Read();
			}
		}
	}
}