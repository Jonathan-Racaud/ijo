using System;
using System.Collections;
namespace ijo.AST;

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

    public this(StringView literal)
    {
        Literal = literal;
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

/*class VariableExpr : Expression
{
    public String Name = new .() ~ delete _;
    public VarType Type;
    public Expression Expression ~ delete _;
}*/

/*class FunctionExpr : Expression
{
    public String Name = new .() ~ delete _;
    public VarType ReturnType;
    public List<VariableExpr> Parameters = new .() ~ DeleteContainerAndItems!(_);
    public List<Expression> Expressions ~ DeleteContainerAndItems!(_);
}*/