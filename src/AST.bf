using System;
using System.Collections;
namespace ijoLang.AST;

enum VarType
{
    case Int;
    case Float;
    case String;
    case Symbol;
    case Array;
    case Dictionary;
    case Struct;
}

interface Expression { }

class NewLineExpression : Expression {}
class NotImplementedExpression : Expression {}

class BinaryExpr : Expression
{
    public Expression Left ~ delete _;
    public Token Operator;
    public Expression Right ~ delete _;

    public this(Expression left, Token op, Expression right)
    {
        Left = left;
        Operator = op;
        Right = right;
    }
}

class UnaryExpr : Expression
{
    public Token Operator;
    public Expression Right ~ delete _;

    public this(Token op, Expression right)
    {
        Operator = op;
        Right = right;
    }
}

class LiteralExpr : Expression
{
    public StringView Literal;
    public TokenType Type;

    public this(StringView literal, TokenType type)
    {
        Literal = literal;
        Type = type;
    }
}

class GroupingExpr : Expression
{
    public Expression Expr ~ delete _;

    public this(Expression expr)
    {
        Expr = expr;
    }
}

class PrintExpr : Expression
{
    public Expression Expr ~ delete _;

    public this(Expression expr)
    {
        Expr = expr;
    }
}

class IdentifierExpr : Expression
{
    public StringView Name;

    public this(StringView name)
    {
        Name = name;
    }
}

class VarExpr : Expression
{
    public StringView Name;
    public Expression Expr ~ delete _;

    public this(StringView name, Expression expr)
    {
        Name = name;
        Expr = expr;
    }
}

class AssignmentExpr : Expression
{
    public Expression Identifier ~ delete _;
    public Expression Assignment ~ delete _;

    public this(Expression identifier, Expression assignment)
    {
        Identifier = identifier;
        Assignment = assignment;
    }
}

class ConditionExpr : Expression
{
    public Expression Condition ~ delete _;
    public List<Expression> Body ~ DeleteContainerAndItems!(_);

    public this(Expression condition, List<Expression> body)
    {
        Condition = condition;
        Body = body;
    }
}

class LoopExpr : Expression
{
    public Expression Initialization ~ delete _;
    public Expression Condition ~ delete _;
    public Expression Increment ~ delete _;
    public List<Expression> Body ~ DeleteContainerAndItems!(_);

    public this(List<Expression> body, Expression condition, Expression initialization, Expression increment)
    {
        Body = body;
        Condition = condition;
        Initialization = initialization;
        Increment = increment;
    }
}

class FunctionExpr : Expression
{
    public StringView Name;
    public List<StringView> Parameters ~ delete _;
    public List<Expression> Body ~ delete _;
    public ReturnType ReturnType;

    public this(StringView name, List<Expression> body, List<StringView> parameters = null, ReturnType returnType = .Undefined)
    {
        Name = name;
        Body = body;
        Parameters = parameters;
        ReturnType = returnType;
    }
}

class FunctionCallExpr : Expression
{
    public StringView Name;
    public List<Expression> Arguments ~ DeleteContainerAndItems!(_);

    public this(StringView name, List<Expression> arguments)
    {
        Name = name;
        Arguments = arguments;
    }
}