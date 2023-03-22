using System;
using System.Collections;
using ijoLang.AST;

namespace ijoLang;

typealias TokenList = List<Token>;
typealias ExpressionList = List<Expression>;

class Parser
{
    int current;
    TokenList tokens;

    bool parsingConditional = false;

    Dictionary<StringView, ReturnType> primitiveTypes = new .()
    {
        ("Int", .Integer),
        ("Double", .Double),
        ("Bool", .Bool),
        ("String", .String),
        ("Undefined", .Undefined)
    } ~ delete _;

    public Result<ExpressionList> Parse(TokenList tokens)
    {
        current = 0;
        this.tokens = tokens;

        let ast = new ExpressionList();
        while (!Match(.EOF))
        {
            parsingConditional = false;

            let res = ParseExpression();
            if (res case .Err) return .Err;

            let expr = res.Value;

            if (expr != null)
            {
                ast.Add(expr);
            }
        }

        return .Ok(ast);
    }

    Result<Expression> ParseExpression()
    {
        if (Match(.NewLine)) return .Ok(new NewLineExpression());

        if (Match(.Print))
        {
            return ParsePrint();
        }
        else if (Match(.Var))
        {
            return ParseVariable();
        }
        else if (Match(.Function))
        {
            return ParseFunction();
        }
        else if (Match(.Condition))
        {
            return ParseConditional();
        }
        else if (Match(.Loop))
        {
            return ParseLoop();
        }
        else if (Match(.Read))
        {
        }
        else if (Match(.StartModule))
        {
        }
        else if (Match(.Import))
        {
        }
        else if (Match(.Undefined))
        {
        }

        let equality = NotError!(ParseEquality());
        /*if (Consume(.NewLine, "Expected end of expression. Expressions end with a new line") case .Err) return .Err;*/

        return equality;
    }

    Result<Expression> ParseEquality()
    {
        var comp = NotError!(ParseComparison());

        while (Match(.BangEqual, .EqualEqual))
        {
            let op = Previous();
            let right = NotError!(ParseComparison());

            comp = new BinaryExpr(comp, op, right);
        }

        return comp;
    }

    Result<Expression> ParseComparison()
    {
        var term = NotError!(ParseTerm());

        while (Match(.Greater, .GreaterEqual, .Less, .LessEqual))
        {
            Token op = Previous();
            let right = NotError!(ParseTerm());

            term = new BinaryExpr(term, op, right);
        }

        return term;
    }

    Result<Expression> ParseTerm()
    {
        var factor = NotError!(ParseFactor());

        while (Match(.Minus, .Plus))
        {
            Token op = Previous();
            let right = NotError!(ParseFactor());

            factor = new BinaryExpr(factor, op, right);
        }

        return factor;
    }

    Result<Expression> ParseFactor()
    {
        var unary = NotError!(ParseUnary());

        while (Match(.Star, .Slash, .Percent))
        {
            Token op = Previous();
            let right = NotError!(ParseUnary());

            unary = new BinaryExpr(unary, op, right);
        }

        return unary;
    }

    Result<Expression> ParseUnary()
    {
        if (Match(.Bang, .Minus))
        {
            Token op = Previous();
            let right = NotError!(ParseUnary());

            return new UnaryExpr(op, right);
        }

        return ParsePrimary();
    }

    Result<Expression> ParsePrimary()
    {
        if (Match(.Integer, .Float, .String, .Symbol))
        {
            return new LiteralExpr(Previous().Literal, Previous().Type);
        }

        if (Match(.Identifier))
        {
            return ParseIdentifier();
        }

        if (Match(.LeftParen))
        {
            var expr = NotError!(ParseExpression());

            if (Consume(.RightParen, "Missing closing ')'") case .Err)
            {
                delete expr;
                return .Err;
            }

            return new GroupingExpr(expr);
        }

        // It is possible to have the following syntax: ?() to
        if (parsingConditional)
            return NotError!(ParseElseConditional());

        Console.WriteLine("Invalid expression");
        return .Err;
    }

    Result<Expression> ParseElseConditional()
    {
        return new NotImplementedExpression();
    }

    Result<Expression> ParsePrint()
    {
        let right = NotError!(ParseExpression());

        return new PrintExpr(right);
    }

    Result<Expression> ParseVariable()
    {
        Consume(.Identifier, "Expected identifier");
        let name = Previous().Literal;

        if (Consume(.Equal) case .Err) return .Err;

        let right = NotError!(ParseExpression());

        return new VarExpr(name, right);
    }

    Result<Expression> ParseIdentifier()
    {
        let identifierLiteral = Previous().Literal;

        if (Match(.Equal))
        {
            let assignment = NotError!(ParseEquality());
            let identifier = new IdentifierExpr(identifierLiteral);

            return new AssignmentExpr(identifier, assignment);
        }

        if (Match(.LeftParen))
        {
            let functionCallArgs = NotError!(ParseFunctionCall());

            return new FunctionCallExpr(identifierLiteral, functionCallArgs);
        }

        return new IdentifierExpr(identifierLiteral);
    }

    Result<List<Expression>> ParseFunctionCall()
    {
        var args = new List<Expression>();

        while (!Match(.RightParen))
        {
            if (Match(.EOF))
            {
                Console.WriteLine("Invalid syntax for function call");
                delete args;
                args = null;
                return .Err;
            }

            let argExpr = NotError!(ParseExpression());
            args.Add(argExpr);

            // We ignore the comma and new line because function calls can have multiple parameters
            // and be written on multiple lines
            //
            // e.g:
            //  add(a, b)
            // or
            //  add(a,
            //      b)
            if (Match(.Comma, .NewLine)) continue;
        }

        return args;
    }

    Result<Expression> ParseConditional()
    {
        parsingConditional = true;

        List<Expression> body = new .();

        var condition = NotError!(ParseEquality());
        
        if (Consume(.RightParen, "Expected ')'") case .Err) return .Err;
        if (Consume(.LeftBrace, "Expected '}'") case .Err) return .Err;

        while (!Match(.RightBrace))
        {
            if (Match(.EOF))
                return .Err;

            let expr = NotError!(ParseExpression());

            if (expr != null)
                body.Add(expr);
        }

        return new ConditionExpr(condition, body);
    }

    Result<Expression> ParseLoop()
    {
        Expression initialization = null;
        Expression condition = null;
        Expression increment = null;

        if (!PeekMatch(.Semicolon))
        {
            initialization = NotError!(ParseExpression());
        }

        if (Match(.Semicolon))
		{
			condition = NotError!(ParseExpression());
		}

        if (Match(.Semicolon))
		{
			increment = NotError!(ParseExpression());
		}

        if (Consume(.RightParen, "Expected ')'") case .Err) return .Err;
        if (Consume(.LeftBrace, "Expected '{'") case .Err) return .Err;

        List<Expression> body = new .();

        while (!Match(.RightBrace))
        {
            if (Match(.EOF))
            {
                Console.WriteLine("Expected '}'");
                return .Err;
            }

            let expr = NotError!(ParseExpression());

            if (expr != null)
                body.Add(expr);
        }

        // ~(cond) {}
        // What we initially parsed as initialization becomes the condition.
        if (initialization != null && condition == null && increment == null)
        {
            return new LoopExpr(body, initialization, null, null);
        }

        // ~(; cond; incr)
        if (initialization == null && condition != null && increment != null)
        {
            return new LoopExpr(body, condition, null, increment);
        }

        // ~(init; cond) {}
        if (initialization != null && condition != null && increment == null)
        {
            return new LoopExpr(body, condition, initialization, null);
        }

        // !(init; cond; incr) {}
        return new LoopExpr(body, condition, initialization, increment);
    }

    // Starts with (
    Result<Expression> ParseFunction()
    {
        StringView name = "";
        // It will be possible to have anonymous functions with the syntax: ($, param1, param2)
        if (Match(.Identifier))
        {
            name = Previous().Literal;
        }

        if (Consume(.Comma, "Function name must be separated from parameters with a comma ','") case .Err) return .Err;

        List<StringView> parameters = new .();
        while (true)
        {
            if (Match(.EOF))
                return .Err;

            let param = Advance().Literal;
            parameters.Add(param);

            if (Match(.RightParen))
                break;

            if (Consume(.Comma, "Function parameters must be separated with a comma ','") case .Err) return .Err;
        }

        ReturnType returnType = .Undefined;
        if (Match(.Return))
        {
            Expression returnTypeIdentifier = null;
            if (Match(.Identifier))
            {
                returnTypeIdentifier = NotError!(ParseIdentifier());
            }

            returnType = MapIdentifierToValue(((IdentifierExpr)returnTypeIdentifier).Name);
        }

        if (Consume(.LeftBrace, "Expected '{'") case .Err) return .Err;

        List<Expression> body = new .();
        while (!Match(.RightBrace))
        {
            if (Match(.EOF))
                return .Err;

            let expr = NotError!(ParseExpression());

            if (expr != null)
                body.Add(expr);
        }

        return new FunctionExpr(name, body, parameters, returnType);
    }

    ReturnType MapIdentifierToValue(StringView name)
    {
        if (primitiveTypes.ContainsKey(name))
            return primitiveTypes.GetValue(name);

        // For now we do not handle user defined types
        return .Undefined;
    }

    Token Advance()
    {
        return tokens[current++];
    }

    Token Previous()
    {
        return tokens[current - 1];
    }

    Result<void> Consume(TokenType type, StringView message = "")
    {
        if (IsSameToken(type))
        {
            Advance();
            return .Ok;
        }

        Console.WriteLine(scope $"Error: {message}");
        return .Err;
    }

    bool Match(params TokenType[] types)
    {
        for (let t in types)
        {
            if (IsSameToken(t))
            {
                Advance();
                return true;
            }
        }

        return false;
    }

    bool PeekMatch(params TokenType[] types)
    {
        for (let t in types)
        {
            if (IsSameToken(t))
            {
                return true;
            }
        }

        return false;
    }

    bool IsSameToken(TokenType type)
    {
        if (current >= tokens.Count) return false;
        return tokens[current].Type == type;
    }
}