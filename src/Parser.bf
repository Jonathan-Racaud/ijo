using System;
using System.Collections;
using ijo.AST;
namespace ijo;

class Parser
{
    int current;
    List<Token> tokens;

    bool parsingConditional = false;

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

        if (Match(.Print))
        {
            return ParsePrint(out expr);
        }
        else if (Match(.Var))
        {
            return ParseVariable(out expr);
        }
        else if (Match(.Identifier))
        {
            return ParseIdentifier(out expr);
        }
        else if (Match(.Condition))
        {
            return ParseConditional(out expr);
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
            return .Ok;
        }
        else if (Match(.NewLine))
        {
            return .Ok;
        }

        return ParseEquality(out expr);
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

        Expression identifier = new IdentifierExpr(Previous().Literal);

        if (Match(.Equal))
        {
            Expression assignment;
            ParseExpression(out assignment);

            outExpr = new AssignmentExpr(identifier, assignment);
            return .Ok;
        }

        outExpr = identifier;
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

        ParseExpression(out initialization);

        if (Match(.Semicolon)) { ParseEquality(out condition); }
        if (Match(.Semicolon)) { ParseEquality(out increment); }

        if (Consume(.RightParen, "Expected ')'") case .Err) return .Err;
        if (Consume(.LeftBrace, "Expected '{'") case .Err) return .Err;

        Expression body;
        ParseExpression(out body);

        if (Consume(.RightBrace, "Expected '}'") case .Err) return .Err;

        if (condition == null && increment == null)
        {
            outExpr = new LoopExpr(body, initialization, null, null);
        }
        else if (increment == null)
        {
            outExpr = new LoopExpr(body, condition, initialization, null);
        }
        else
        {
            outExpr = new LoopExpr(body, condition, initialization, increment);
        }

        return .Ok;
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

    bool IsSameToken(TokenType type)
    {
        if (current >= tokens.Count) return false;
        return tokens[current].Type == type;
    }
}