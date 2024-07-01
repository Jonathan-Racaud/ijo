using System;
using System.Collections;

namespace ijo;

class Parser
{
    private Scanner scanner;

    private Token previous;
    private Token current;

    private bool hadError;
    private bool parsingLoop;

    // Declared in the order of the TokenType enum
    private ParseRule[] rules = new ParseRule[TokenType.EOL.Underlying + 1];

    private Precedence precedence;

    private int scopeDepth = 0;

    public this(Scanner scanner)
    {
        this.scanner = scanner;
        InitRules();
    }

    public ~this()
    {
        for (var rule in rules)
        {
            DeleteIfNotNull!(rule.Prefix);
            DeleteIfNotNull!(rule.Infix);
        }
        delete rules;
    }

    public Result<ExprList> Parse()
    {
        Advance();

        let expressions = new List<Expr>();

        while (!Match(.EOF))
        {
            if (Match(.EOL))
                continue;

            expressions.Add(InternalParse());
        }

        if (expressions.Count == 0)
            return .Err;

		// TODO: Check if we still need this
        /*if (expressions.Count > 1)
        {
			return .Block(expressions);
        }*/

        return expressions;
    }

    Expr InternalParse()
    {
        Expr expression = .Error;

        if (Match(.Const))
            expression = ConstExpression();
        else if (Match(.Var))
            expression = VarDefExpression();
        else if (Match(.Struct))
            expression = StructExpression();
        else if (Match(.Return))
            expression = ReturnExpression();
        else
            expression = StatementExpression();

        if (expression == .Error)
            return SError!(ParserError.InvalidExpression);

        return expression;
    }

    Expr StatementExpression()
    {
        if (Match(.Builtin))
            return BuiltinExpression();
        else if (Match(.If))
            return IfExpression();
        else if (Match(.Switch))
            return SwitchExpression();
        else if (Match(.Loop))
            return LoopExpression();
        else if (Match(.LeftBrace))
            return BlockExpression();

        let expression = Expression();

        if (!parsingLoop && !Check(.EOF) && !Check(.RightBrace) && !Check(.Dot))
        {
            if (Consume(.EOL, ParserError.MultipleExpressionPerLine) case .Err)
                return SError!(ParserError.MultipleExpressionPerLine);
        }

        return expression;
    }

    Expr ConstExpression()
    {
        let identifier = previous.Identifier;

        if (Check(.EOF) || Check(.EOL))
        {
            return SError!(ParserError.MultipleExpressionPerLine);
        }

		return .ConstDefinition(new .(identifier, Expression()));
    }

    Expr VarDefExpression()
    {
        if (scopeDepth == 0)
        {
            return SError!(ParserError.GlobalScopeVariable);
        }

        StringView name;

        if (ParseVariable(ParserError.ExpectedVariableName) case .Ok(let val))
        {
            name = val;
        }
        else
        {
            return SError!(ParserError.ExpectedVariableName);
        }

		Expr expression = .Error;

        if (Match(.Equal))
            expression = Expression();
        else
            ErrorAtCurrent(ParserError.DeclarationMustHaveValue);

        if (!parsingLoop)
        {
            if (Consume(.EOL, ParserError.MultipleExpressionPerLine) case .Err)
                return SError!(ParserError.MultipleExpressionPerLine);
        }

		return .VarDefinition(new .(name, expression));
    }

    Result<StringView> ParseVariable(StringView errorMessage)
    {
        if (Match(.Identifier))
        {
            return previous.Literal;
        }

        return "";
    }

    Expr StructExpression()
    {
        let identifier = previous.Identifier;
        let body = BlockExpression();

		return .ConstDefinition(new .(identifier, body));
    }

    Expr ReturnExpression()
    {
		// TODO: Reimplement
        /*if (Match(.EOL))
            return SReturn!(SSuccess!());

        let expression = Expression();

        if (Consume(.EOL, ParserError.MultipleExpressionPerLine) case .Err)
	        return SError!(ParserError.MultipleExpressionPerLine);

        return SReturn!(expression);*/
		return SError!(ParserError.NotImplemented);
    }

    Expr BuiltinExpression()
    {
        let name = previous.Literal;

        if (Consume(.LeftParen, ParserError.MissingLeftParen) case .Err)
        {
            Console.Error.WriteLine(ParserError.MissingLeftParen);
            return SError!(ParserError.MissingLeftParen);
        }

        let parameters = new List<Expr>();
        var hadError = false;
        defer {
            if (hadError) ClearAndDisposeItems!(parameters);
		}

        while (!Check(.RightParen) && !Check(.EOF))
        {
            parameters.Add(Expression());
            if (Match(.Comma)) continue;
        }

        if (Consume(.RightParen, ParserError.MissingRightParen) case .Err)
        {
            Console.Error.WriteLine(ParserError.MissingRightParen);
            hadError = true;
            return SError!(ParserError.MissingRightParen);
        }

		return .FunctionCall(name, parameters);
    }

    Expr IfExpression()
    {
        let condition = Expression();

        if (Consume(.RightParen, ParserError.MissingRightParen) case .Err)
            return SError!(ParserError.MissingRightParen);

        let body = StatementExpression();

        if (Match(.Else))
        {
            let otherwise = StatementExpression();

			return .Conditional(new .() { condition, body, otherwise });
        }

		return .Conditional(new .() { condition, body });
    }

    /**
    ?{expression}
      42 {
	    \>>("The answer to everthying, the universe and the rest" )
      }
      "Hello" {
	    \>>("Goodbye")
      }
     _0 > 18 && _0 < 65 {}
	?() {}
	*/
    Expr SwitchExpression()
    {
		// TODO: Reimplement
        /*var expressions = new List<Expr>();
        let identifier = "_0";
        let _0 = Expr.ConstDefinition(new .(identifier, Expression()));

        expressions.Add(_0);

        if (Consume(.RightBrace, ParserError.MissingRightBrace) case .Err)
	        return SError!(ParserError.MissingRightBrace);

        while (!Check(.Else) && !Check(.EOF))
        {
            if (Check(.EOL))
                Advance();

            if (Check(.Else))
	            break;

            let condition = Expression();

            if (Consume(.LeftBrace, ParserError.MissingLeftBrace) case .Err)
	            return SError!(ParserError.MissingLeftBrace);

            let body = BlockExpression();
            switch (condition.Expression)
            {
            case .Integer, .Double, .Bool, .Success, .Literal, .String, .BuiltinCall, .UserCall:
                expressions.Add(SConditional!(SOperator!("==", SLiteral!(identifier), condition), body, null));
            default:
                delete condition;
                delete body;
                expressions.Add(SError!(ParserError.InvalidExpression));
            }
        }

        if (Consume(.Else, ParserError.ExpectedSwitchDefault) case .Err)
	        return SError!(ParserError.ExpectedSwitchDefault);

        if (Consume(.LeftBrace, ParserError.MissingLeftBrace) case .Err)
	        return SError!(ParserError.MissingLeftBrace);

        expressions.Add(BlockExpression());

        return SSwitch!(expressions);*/
		return SError!(ParserError.NotImplemented);
    }

    bool CheckIsOperator()
    {
        switch (current.Type)
        {
        case .EqualEqual, .Less, .LessEqual, .Greater, .GreaterEqual, .BangEqual:
            return true;
        default:
            return false;
        }
    }    

    Expr LoopExpression()
    {
        if (Match(.Semicolon))
            return SError!(ParserError.IncorrectLoop);

        Expr loop = .Error;
        var hadError = false;
        defer {
            if (loop != .Error && hadError) loop.Dispose();
		}

        Expr first = .Error;
        Expr second = .Error;
        Expr third = .Error;
        Expr body = .Error;

        var parsedStatement = 0;

        parsingLoop = true;

        if (Match(.RightParen))
        {
            body = ParseLoopBody!();
        }
        else
        {
            if (Match(.Var))
            {
                first = VarDefExpression();
                parsedStatement++;
            }
            else
            {
                first = Expression();
                parsedStatement++;
            }

            if (Match(.Semicolon))
            {
                if (Match(.Var))
                {
                    ErrorAtCurrent(ParserError.ExpectedBooleanExpression);
                    parsingLoop = false;
                    hadError = true;

                    return SError!(ParserError.ExpectedBooleanExpression);
                }

                second = Expression();
                parsedStatement++;
            }

            if (Match(.Semicolon))
            {
                if (Match(.Var))
                {
                    ErrorAtCurrent(ParserError.ExpectedBooleanExpression);
                    parsingLoop = false;
                    hadError = true;

                    return SError!(ParserError.ExpectedBooleanExpression);
                }

                third = Expression();
                parsedStatement++;
            }

            if (Consume(.RightParen, ParserError.MissingRightParen) case .Err)
            {
                hadError = true;
                return SError!(ParserError.MissingRightParen);
            }

            body = ParseLoopBody!();
        }

        switch (parsedStatement)
        {
        case 0: // Infinite loop
            loop = .Loop(new .() { body });
        case 1: // ~(condition) {}
            loop = .Loop(new .() { first, body });
        case 2: // ~(condition; increment) {}
            loop = .Loop(new .() { first, second, body });
        case 3: // ~(init; condition; increment) {}
            loop = .Loop(new .() { first, second, third, body });
        default:
            ErrorAtCurrent(ParserError.IncorrectLoop);
            hadError = true;
            return SError!(ParserError.IncorrectLoop);
        }

        return loop;
    }

    mixin ParseLoopBody()
    {
        if (!Match(.LeftBrace))
        {
            ErrorAtCurrent(ParserError.MissingLeftBrace);
            hadError = true;
            return SError!(ParserError.MissingLeftBrace);
        }

        BlockExpression()
    }

    Expr BlockExpression()
    {
        let expressions = new List<Expr>();

        scopeDepth++;
        defer { scopeDepth--; }

        while (!Check(.RightBrace) && !Check(.EOF))
        {
            if (Check(.EOL))
            {
                Advance();
                continue;
            }

            expressions.Add(InternalParse());
        }

        if (Consume(.RightBrace, ParserError.MissingRightBrace) case .Err)
        {
            ClearAndDisposeItems!(expressions);
            return SError!(ParserError.MissingRightBrace);
        }

		return .Block(expressions);
    }

    Expr Expression()
    {
        return Precedence(.Assignment);
    }

    Expr Precedence(Precedence expected)
    {
        Advance();

        let rule = GetRuleFrom(previous.Type);

        /*if (!(current.Type.Underlying & rule.AcceptedTokens.Underlying == 0))*/
        if (!current.Type.HasFlag(rule.AcceptedTokens))
        {
            ErrorAt(current, ParserError.InvalidToken);
        }

        if (rule.Prefix == null)
        {
            Console.Error.WriteLine(ParserError.ExpectedExpression);
            return SError!(ParserError.ExpectedExpression);
        }

        precedence = expected;
        let prefix = rule.Prefix();

        while (precedence <= GetRuleFrom(current.Type).Precedence)
        {
            Advance();

            let op = previous;
            let infixRule = GetRuleFrom(previous.Type).Infix;

            let infix = infixRule();

			return .FunctionCall(op.Literal, new .() { prefix, infix });
        }

        return prefix;
    }

    Expr Unary()
    {
        let operatorType = previous;
        let expression = Precedence(.Unary);

		return .FunctionCall(operatorType.Literal, new .() { expression });
    }

    Expr Binary()
    {
        let rule = GetRuleFrom(previous.Type);

        return Precedence(rule.Precedence + 1);
    }

    Expr Grouping()
    {
        var expressions = new List<Expr>();

        while (!Check(.RightParen) && !Check(.EOF))
        {
            if (!Check(.EOL))
                Advance();

            expressions.Add(Expression());
        }

        if (Consume(.RightParen, ParserError.MissingRightParen) case .Err)
		{
			DeleteContainerAndDisposeItems!(expressions);
            return SError!(ParserError.MissingRightParen);
		}

		return .Block(expressions);
    }

    Expr Integer()
    {
        return .Int(Int.Parse(previous.Literal));
    }

    Expr Double()
    {
        return .Double(Double.Parse(previous.Literal));
    }

    Expr String()
    {
        let str = new String(previous.Literal);
        str.TrimStart('"');
        str.TrimEnd('"');

        return .String(str);
    }

    Expr InterpolatedString()
    {
        return SError!(ParserError.NotImplemented);
    }

    Expr Identifier()
    {
        let identifier = previous.Literal;
        var canAssign = precedence <= .Assignment;

        switch (identifier)
        {
        case "@true": return .Bool(true);
        case "@false": return .Bool(false);
        default: break;
        }

        if (canAssign && Match(.Equal))
        {
            let expression = Expression();

			return .SetIdentifier(new .(identifier, expression));
        }

        if (Match(.LeftParen))
        {
            return FunctionCall(identifier);
        }

		return .GetIdentifier(previous.Literal);
    }

    Expr FunctionCall(StringView identifier)
    {
        let expressions = new List<Expr>();

        while (!Check(.RightParen) && !Check(.EOF))
        {
            expressions.Add(Expression());

            if (Check(.Comma))
            {
                Advance();
            }
            else if (!Check(.RightParen))
            {
                ClearAndDisposeItems!(expressions);
                ErrorAtCurrent(ParserError.InvalidExpression);
                return SError!(ParserError.InvalidExpression);
            }
        }

        if (Consume(.RightParen, ParserError.MissingRightParen) case .Err)
            return SError!(ParserError.MissingRightParen);

		return .FunctionCall(identifier, expressions);
    }

    Expr FunctionDef()
    {
        let type = previous.Type;
        let identifier = type == .Func ? previous.Identifier : "anon";

        // We do not need to consume the '(' as it has already been scanned and is part of
        // the literal for the token. It was consume to know we were dealing with a function
        // since there's no keyword for defining functions.

        let parameters = new List<String>();

        while (!Check(.RightParen) && !Check(.EOF))
        {
            Advance();
            parameters.Add(new .(previous.Literal));

            if (!Check(.RightParen) && Consume(.Comma, ParserError.ExpectedComma) case .Err)
                return SError!(ParserError.ExpectedComma);
        }

        if (Consume(.RightParen, ParserError.MissingRightParen) case .Err)
	        return SError!(ParserError.MissingRightParen);

        if (Consume(.LeftBrace, ParserError.MissingLeftBrace) case .Err)
            return SError!(ParserError.MissingLeftBrace);

        let body = BlockExpression();

		// TODO: Reimplement
        /*if (type case .Lambda)
            return SLambda!(parameters, body);
        else
            return SDefFunc!(identifier, parameters, body);*/

		return .FunctionDefinition(identifier, parameters, new .() { body });
    }

    Expr Literal() => Identifier();


    Expr And()
    {
        return Precedence(.And);
    }

    Expr Or()
    {
        return Precedence(.Or);
    }

    Expr Noop() => .Undefined;

    void Advance()
    {
        previous = current;

        while (true)
        {
            current = scanner.Scan();

            if (current.Type != .Error) break;

            ErrorAtCurrent("");
        }
    }

    bool Match(TokenType expected)
    {
        if (!Check(expected))
        {
            return false;
        }

        Advance();
        return true;
    }

    bool Check(TokenType expected) => current.Type == expected;

    Result<void> Consume(TokenType expected, StringView message)
    {
        if (current.Type == expected)
        {
            Advance();
            return .Ok;
        }

        ErrorAtCurrent(message);

        return .Err;
    }

    void ErrorAt(Token token, StringView message)
    {
        Console.Error.Write(scope $"line {token.Line} ");

        if (token.Type == .EOF)
        {
            Console.Error.Write(" at end ");
        }
        else if (token.Type == .Error)
        {
            // Nothing
        }
        else
        {
            Console.Error.Write(scope $" at {token.Literal} ");
        }

        Console.Error.WriteLine(message);

        hadError = true;
    }

    void ErrorAtCurrent(StringView message)
    {
        ErrorAt(previous, message);
    }

    private void InitRules()
    {
        rules[TokenType.Comma.Underlying]      = .(null, null, .None, .All);
        rules[TokenType.Dot.Underlying]        = .(new => Expression, null, .None, .All);
        rules[TokenType.LeftBrace.Underlying]  = .(null, null, .None, .All);
        rules[TokenType.LeftParen.Underlying]  = .(new => Grouping, null, .None, .All);
        rules[TokenType.Minus.Underlying]      = .(new => Unary, new => Binary, .Term, .Integer | .Double);
        rules[TokenType.Plus.Underlying]       = .(null, new => Binary, .Term, .Integer | .Double);
        rules[TokenType.RightBrace.Underlying] = .(null, null, .None, .All);
        rules[TokenType.RightParen.Underlying] = .(null, null, .None, .All);
        rules[TokenType.Semicolon.Underlying]  = .(null, null, .None, .All);
        rules[TokenType.Slash.Underlying]      = .(null, new => Binary, .Factor, .Integer | .Double);
        rules[TokenType.Star.Underlying]       = .(null, new => Binary, .Factor, .Integer | .Double);
        rules[TokenType.Percent.Underlying]    = .(null, new => Binary, .None, .All);

        rules[TokenType.Bang.Underlying]         = .(new => Unary, null, .None, .All);
        rules[TokenType.BangEqual.Underlying]    = .(null, new => Binary, .Equality, .All);
        rules[TokenType.Equal.Underlying]        = .(null, null, .None, .All);
        rules[TokenType.EqualEqual.Underlying]   = .(null, new => Binary, .Equality, .All);
        rules[TokenType.Greater.Underlying]      = .(null, new => Binary, .Comparison, .All);
        rules[TokenType.GreaterEqual.Underlying] = .(null, new => Binary, .Comparison, .All);
        rules[TokenType.Less.Underlying]         = .(null, new => Binary, .Comparison, .All);
        rules[TokenType.LessEqual.Underlying]    = .(null, new => Binary, .Comparison, .All);

        rules[TokenType.Identifier.Underlying]         = .(new => Identifier, null, .None, .All);
        rules[TokenType.Integer.Underlying]            = .(new => Integer, null, .None, .All);
        rules[TokenType.Double.Underlying]             = .(new => Double, null, .None, .All);
        rules[TokenType.String.Underlying]             = .(new => String, null, .None, .All);
        rules[TokenType.InterpolatedString.Underlying] = .(new => InterpolatedString, null, .None, .All);

        rules[TokenType.And.Underlying]     = .(null, new => And, .And, .All);
        rules[TokenType.Array.Underlying]   = .(null, null, .None, .All);
        rules[TokenType.Assert.Underlying]  = .(null, null, .None, .All);
        rules[TokenType.Else.Underlying]    = .(null, null, .None, .All);
        rules[TokenType.Enum.Underlying]    = .(null, null, .None, .All);
        rules[TokenType.False.Underlying]   = .(new => Literal, null, .None, .All);
        rules[TokenType.Func.Underlying]    = .(new => FunctionDef, null, .None, .All);
        rules[TokenType.Lambda.Underlying]  = .(new => FunctionDef, null, .None, .All);
        rules[TokenType.If.Underlying]      = .(null, null, .None, .All);
        rules[TokenType.Map.Underlying]     = .(null, null, .None, .All);
        rules[TokenType.Module.Underlying]  = .(null, null, .None, .All);
        rules[TokenType.Or.Underlying]      = .(null, new => Or, .Or, .All);
        rules[TokenType.Builtin.Underlying] = .(null, null, .None, .All);
        rules[TokenType.Return.Underlying]  = .(new => ReturnExpression, null, .None, .All);
        rules[TokenType.Struct.Underlying]  = .(null, null, .None, .All);
        rules[TokenType.This.Underlying]    = .(null, null, .None, .All);
        rules[TokenType.True.Underlying]    = .(new => Literal, null, .None, .All);
        rules[TokenType.Var.Underlying]     = .(null, null, .None, .All);
        rules[TokenType.Loop.Underlying]    = .(null, null, .None, .All);

        rules[TokenType.Error.Underlying] = .(null, null, .None, .All);
        rules[TokenType.EOL.Underlying]   = .(new => Noop, new => Noop, .None, .All);
        rules[TokenType.EOF.Underlying]   = .(new => Noop, new => Noop, .None, .All);
    }

    ParseRule GetRuleFrom(TokenType type)
    {
        return rules[type.Underlying];
    }
}

enum Precedence
{
    None,
    Assignment,
    Or,
    And,
    Equality,
    Comparison,
    Term,
    Factor,
    Unary,
    Call,
    Primary
}

typealias ParseFunc = delegate Expr();

struct ParseRule: this(ParseFunc Prefix, ParseFunc Infix, Precedence Precedence, TokenType AcceptedTokens);

enum ParserError
{
    public const StringView MultipleExpressionPerLine = "Only one expression per line accepted";
    public const StringView NotImplemented = "Feature not implemented yet.";
    public const StringView MissingLeftBrace = "Expected '{'";
    public const StringView MissingRightBrace = "Expected '}' after expression";
    public const StringView MissingLeftParen = "Expected '('";
    public const StringView MissingRightParen = "Expected ')' after expression";
    public const StringView ExpectedExpression = "Expected an expression";
    public const StringView InvalidToken = "Invalid token";
    public const StringView InvalidExpression = "Invalid expression";
    public const StringView FailedParsing = "Failed to parse program";
    public const StringView GlobalScopeVariable = "Global scope can't have variables. Only constants, functions (call, def) and type def";
    public const StringView ExpectedVariableName = "Expected variable name";
    public const StringView DeclarationMustHaveValue = "Declaration must have a value";
    public const StringView IncorrectLoop = "Loop must be specified as one of:\n  ~(initializer; condition; increment) {...}\n  ~(condition;increment){...}\n  ~(condition){...}\n  ~(){...}";
    public const StringView ExpectedBooleanExpression = "Expected boolean expression";
    public const StringView ExpectedComma = "Expected a comma";
    public const StringView MissingPipe = "Expected '|'";
    public const StringView ExpectedSwitchDefault = "Switch statements must be terminated by '?()'";
}