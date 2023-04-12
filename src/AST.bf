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

class Ast
{
    public List<Expression> Expressions ~ DeleteContainerAndItems!(_);
    public StringView ModuleName;

    public this(StringView moduleName, List<Expression> expressions)
    {
        ModuleName = moduleName;
        Expressions = expressions;
    }

    public void Print(int level = 0)
    {
        for (let e in Expressions) {
            e.Print(level);
		}
    }
}

interface Expression {
    public void Print(int level);
}

class NewLineExpression : Expression {
    public void Print(int level) {}
}
class NotImplementedExpression : Expression {
    public void Print(int level) { Console.WriteLine("<<NOT IMPLEMENTED>>"); }
}

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

    public void Print(int level)
	{
        Console.Write(scope String(' ', level * 2));
		Console.WriteLine("BinaryExpr:");
        Left.Print(level + 1);
        Console.Write(scope String(' ', level * 4));
        Console.WriteLine(scope $"Operator({Operator.Literal})");
        Right.Print(level + 1);
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

    public void Print(int level)
    {
        Console.Write(scope String(' ', level * 2));
    	Console.WriteLine("UnaryExpr:");
        Console.Write(scope String(' ', level * 3));
        Console.WriteLine(scope $"Operator({Operator.Literal})");
        Right.Print(level + 1);
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

    public void Print(int level)
    {
        Console.Write(scope String(' ', level * 2));
    	Console.WriteLine(scope $"LiteralExpr({Type} {Literal.QuoteString(..scope .())})");
    }
}

class GroupingExpr : Expression
{
    public Expression Expr ~ delete _;

    public this(Expression expr)
    {
        Expr = expr;
    }

    public void Print(int level)
    {
        Console.Write(scope String(' ', level * 2));
    	Console.WriteLine(scope $"GroupingExpr:(");
        Expr.Print(level + 1);
        Console.Write(scope String(' ', level * 2));
        Console.WriteLine(scope $")");
    }
}

class PrintExpr : Expression
{
    public Expression Expr ~ delete _;

    public this(Expression expr)
    {
        Expr = expr;
    }

    public void Print(int level)
    {
        Console.Write(scope String(' ', level * 2));
    	Console.WriteLine(scope $"PrintExpr:");
        Expr.Print(level + 1);
    }
}

class IdentifierExpr : Expression
{
    public StringView Name;

    public this(StringView name)
    {
        Name = name;
    }

    public void Print(int level)
    {
        Console.Write(scope String(' ', level * 2));
    	Console.WriteLine(scope $"IdentifierExpr({Name})");
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

    public void Print(int level)
    {
        Console.Write(scope String(' ', level * 2));
    	Console.WriteLine(scope $"VarExpr({Name})");
        Expr.Print(level + 1);
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

    public void Print(int level)
    {
        Console.Write(scope String(' ', level * 2));
    	Console.WriteLine(scope $"AssignmentExpr:");
        Identifier.Print(level + 1);
        Assignment.Print(level + 1);
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

    public void Print(int level)
    {
        Console.Write(scope String(' ', level * 2));
    	Console.WriteLine(scope $"ConditionExpr:");
        Console.Write(scope String(' ', (level + 1)));
        Console.WriteLine(scope $"Condition:");
        Condition.Print(level + 1);

        Console.Write(scope String(' ', (level + 1)));
        Console.WriteLine(scope $"Instructions:");
        for (var instruction in Body) {
            instruction.Print(level + 1);
		}
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

    public void Print(int level)
    {
        Console.Write(scope String(' ', level * 2));
    	Console.WriteLine(scope $"LoopExpr:");
        

        if (Initialization != null)
        {
            Console.Write(scope String(' ', level * 3));
			Console.WriteLine(scope $"Initialization:");
            Initialization.Print(level + 1);
        }

        if (Condition != null)
        {
            Console.Write(scope String(' ', level * 3));
            Console.WriteLine(scope $"Condition:");
            Condition.Print(level + 1);
        }

        if (Increment != null)
        {
            Console.Write(scope String(' ', level * 3));
            Console.WriteLine(scope $"Increment:");
            Increment.Print(level + 1);
        }

        Console.Write(scope String(' ', level * 3));
        Console.WriteLine(scope $"Instructions:");
        for (var instruction in Body) {
            instruction.Print(level + 1);
    	}
    }
}

class FunctionExpr : Expression
{
    public StringView Name;
    public List<ParameterDefinition> Parameters ~ delete _;
    public List<Expression> Body ~ DeleteContainerAndItems!(_);
    public ReturnType ReturnType;

    public this(StringView name, List<Expression> body, List<ParameterDefinition> parameters = null, ReturnType returnType = .Undefined)
    {
        Name = name;
        Body = body;
        Parameters = parameters;
        ReturnType = returnType;
    }

    public void Print(int level)
    {
        Console.Write(scope String(' ', level * 2));
    	Console.WriteLine(scope $"FunctionExpr({Name}, {ReturnType}):");
        for (var param in Parameters) {
            Console.Write(scope String(' ', level + 1));
            Console.WriteLine(scope $"Param({param.OuterName}, {param.InnerName}, {param.TypeName})");
    	}

        Console.Write(scope String(' ', level + 1));
        Console.WriteLine("Instructions:");
        for (var instruction in Body) {
            instruction.Print(level + 1);
        }
    }
}

struct ParameterDefinition
{
    public StringView? OuterName;
    public StringView InnerName;
    public StringView TypeName;
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

    public void Print(int level)
    {
        Console.Write(scope String(' ', level * 2));
    	Console.WriteLine(scope $"FunctionCallExpr({Name}):");

        for (var param in Arguments) {
            Console.Write(scope String(' ', level * 2));
            Console.WriteLine(scope $"Argument:");
            param.Print(level + 1);
    	}
    }
}