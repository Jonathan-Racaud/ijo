using System;
using System.Collections;
using ijoLang.AST;
namespace ijoLang;

class Parser
{
    int current;
    List<Token> tokens;

    bool parsingConditional = false;

    Dictionary<StringView, ReturnType> primitiveTypes = new .()
        {
            ("Int", .Integer),
            ("Double", .Double),
            ("Bool", .Bool),
            ("String", .String),
            ("Symbol", .Symbol),
            ("Undefined", .Undefined)
        } ~ delete _;

    public Result<void> Parse(List<Token> toks, List<Expression> expressions)
    {
        current = 0;
        this.tokens = toks;

        while (!Match(.EOF))
        {
            parsingConditional = false;

            Expression expr;
            if (ParseExpression(out expr) case .Err) return .Err;

            if (expr != null)
            {
                expressions.Add(expr);
            }
        }

        return .Ok;
    }

    Result<void> ParseExpression(out Expression expr)
    {
        expr = null;

        if (Match(.NewLine)) return .Ok;

        if (Match(.Print))
        {
            return ParsePrint(out expr);
        }
        else if (Match(.Var))
        {
            return ParseVariable(out expr);
        }
        else if (Match(.Function))
        {
            return ParseFunction(out expr);
        }
        else if (Match(.Condition))
        {
            return ParseConditional(out expr);
        }
        else if (Match(.Loop))
        {
            return ParseLoop(out expr);
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

        if (ParseEquality(out expr) case .Err) return .Err;
        /*if (Consume(.NewLine, "Expected end of expression. Expressions end with a new line") case .Err) return .Err;*/

        return .Ok;
    }

    Result<void> ParseEquality(out Expression outExpr)
    {
        outExpr = null;
        Expression expr;

        if (ParseComparison(out expr) case .Err) return .Err;

        while (Match(.BangEqual, .EqualEqual))
        {
            let op = Previous();

            Expression right;
            if (ParseComparison(out right) case .Err) return .Err;

            expr = new BinaryExpr(expr, op, right);
        }

        outExpr = expr;
        return .Ok;
    }

    Result<void> ParseComparison(out Expression outExpr)
    {
        outExpr = null;
        Expression expr;

        if (ParseTerm(out expr) case .Err) return .Err;

        while (Match(.Greater, .GreaterEqual, .Less, .LessEqual))
        {
            Token op = Previous();
            Expression right;
            if (ParseTerm(out right) case .Err) return .Err;
            expr = new BinaryExpr(expr, op, right);
        }

        outExpr = expr;
        return .Ok;
    }

    Result<void> ParseTerm(out Expression outExpr)
    {
        outExpr = null;
        Expression expr;

        if (ParseFactor(out expr) case .Err) return .Err;

        while (Match(.Minus, .Plus))
        {
            Token op = Previous();
            Expression right;
            if (ParseFactor(out right) case .Err) return .Err;

            expr = new BinaryExpr(expr, op, right);
        }

        outExpr = expr;
        return .Ok;
    }

    Result<void> ParseFactor(out Expression outExpr)
    {
        outExpr = null;
        Expression expr;

        if (ParseUnary(out expr) case .Err) return .Err;

        while (Match(.Star, .Slash, .Percent))
        {
            Token op = Previous();
            Expression right;
            if (ParseUnary(out right) case .Err) return .Err;

            expr = new BinaryExpr(expr, op, right);
        }

        outExpr = expr;
        return .Ok;
    }

    Result<void> ParseUnary(out Expression outExpr)
    {
        outExpr = null;

        if (Match(.Bang, .Minus))
        {
            Token op = Previous();
            Expression right;
            if (ParseUnary(out right) case .Err) return .Err;

            outExpr = new UnaryExpr(op, right);
            return .Ok;
        }

        return ParsePrimary(out outExpr);
    }

    Result<void> ParsePrimary(out Expression outExpr)
    {
        outExpr = null;

        if (Match(.Integer, .Float, .String, .Symbol))
        {
            outExpr = new LiteralExpr(Previous().Literal, Previous().Type);
            return .Ok;
        }

        if (Match(.Identifier))
        {
            Expression identifier;
            ParseIdentifier(out identifier);

            outExpr = identifier;
            return .Ok;
        }

        if (Match(.LeftParen))
        {
            Expression expr;

            if (ParseExpression(out expr) case .Err) return .Err;

            if (Consume(.RightParen, "Missing closing ')'") case .Err)
            {
                delete expr;
                return .Err;
            }

            outExpr = new GroupingExpr(expr);
            return .Ok;
        }

        // It is possible to have the following syntax: ?() to
        if (parsingConditional)
            return .Ok;

        Console.WriteLine("Invalid expression");
        return .Err;
    }

    Result<void> ParsePrint(out Expression outExpr)
    {
        outExpr = null;

        Expression right;
        if (ParseExpression(out right) case .Err) return .Err;

        outExpr = new PrintExpr(right);
        return .Ok;
    }

    Result<void> ParseVariable(out Expression outExpr)
    {
        outExpr = null;

        Consume(.Identifier, "Expected identifier");
        let name = Previous().Literal;

        if (Consume(.Equal) case .Err) return .Err;

        Expression right;
        if (ParseExpression(out right) case .Err)
        {
            if (right != null)
                delete right;
            return .Err;
        }

        outExpr = new VarExpr(name, right);

        return .Ok;
    }

    Result<void> ParseIdentifier(out Expression outExpr)
    {
        outExpr = null;

        let identifierLiteral = Previous().Literal;

        if (Match(.Equal))
        {
            Expression assignment;
            ParseEquality(out assignment);

            Expression identifier = new IdentifierExpr(identifierLiteral);
            outExpr = new AssignmentExpr(identifier, assignment);
            return .Ok;
        }

        if (Match(.LeftParen))
        {
            List<Expression> args;
            ParseFunctionCall(out args);

            outExpr = new FunctionCallExpr(identifierLiteral, args);
            return .Ok;
        }

        Expression identifier = new IdentifierExpr(identifierLiteral);
        outExpr = identifier;
        return .Ok;
    }

    Result<void> ParseFunctionCall(out List<Expression> args)
    {
        args = new .();

        while (!Match(.RightParen))
        {
            if (Match(.EOF))
            {
                Console.WriteLine("Invalid syntax for function call");
                delete args;
                args = null;
                return .Err;
            }

            Expression argExpr;
            if (ParseExpression(out argExpr) case .Err)
            {
                delete args;
                args = null;
                return .Err;
            }
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

        return .Ok;
    }

    Result<void> ParseConditional(out Expression outExpr)
    {
        outExpr = null;
        parsingConditional = true;

        Expression condition = null;
        List<Expression> body = new .();

        if (ParseEquality(out condition) case .Err) return .Err;
        if (Consume(.RightParen, "Expected ')'") case .Err) return .Err;
        if (Consume(.LeftBrace, "Expected '}'") case .Err) return .Err;

        while (!Match(.RightBrace))
        {
            if (Match(.EOF))
                return .Err;

            Expression expr;
            if (ParseExpression(out expr) case .Err) return .Err;

            if (expr != null)
                body.Add(expr);
        }

        outExpr = new ConditionExpr(condition, body);
        return .Ok;
    }

    Result<void> ParseLoop(out Expression outExpr)
    {
        outExpr = null;

        Expression initialization = null;
        Expression condition = null;
        Expression increment = null;

        if (!PeekMatch(.Semicolon))
            ParseExpression(out initialization);

        if (Match(.Semicolon)) { ParseExpression(out condition); }
        if (Match(.Semicolon)) { ParseExpression(out increment); }

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

            Expression expr;
            if (ParseExpression(out expr) case .Err) return .Err;

            if (expr != null)
                body.Add(expr);
        }

        // ~(cond) {}
        // What we initially parsed as initialization becomes the condition.
        if (initialization != null && condition == null && increment == null)
        {
            outExpr = new LoopExpr(body, initialization, null, null);
        }
        // ~(; cond; incr)
        else if (initialization == null && condition != null && increment != null)
        {
            outExpr = new LoopExpr(body, condition, null, increment);
        }
        // ~(init; cond) {}
        else if (initialization != null && condition != null && increment == null)
        {
            outExpr = new LoopExpr(body, condition, initialization, null);
        }
        // !(init; cond; incr) {}
        else
        {
            outExpr = new LoopExpr(body, condition, initialization, increment);
        }

        return .Ok;
    }

    // Starts with (
    Result<void> ParseFunction(out Expression outExpr)
    {
        outExpr = null;

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
                if (ParseIdentifier(out returnTypeIdentifier) case .Err) return .Err;

            returnType = MapIdentifierToValue(((IdentifierExpr)returnTypeIdentifier).Name);
        }

        if (Consume(.LeftBrace, "Expected '{'") case .Err) return .Err;

        List<Expression> body = new .();
        while (!Match(.RightBrace))
        {
            if (Match(.EOF))
                return .Err;

            Expression expr;
            if (ParseExpression(out expr) case .Err) return .Err;

            if (expr != null)
                body.Add(expr);
        }

        outExpr = new FunctionExpr(name, body, parameters, returnType);

        return .Ok;
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