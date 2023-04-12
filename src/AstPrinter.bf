using System;
using System.Collections;
using ijoLang.AST;

namespace ijoLang;

class AstPrinter
{
    public void Print(List<Expression> expressions)
    {
        for (let expr in expressions)
        {
            Print(expr, 0);
        }
    }

    void Print(Expression expression, int level = 0)
    {
        switch (expression.GetType()) {
        case typeof(BinaryExpr): PrintBinary(expression as BinaryExpr, level);
        case typeof(LiteralExpr): PrintLiteral(expression as LiteralExpr, level);
        case typeof(UnaryExpr): PrintUnary(expression as UnaryExpr, level);
        case typeof(GroupingExpr): PrintGrouping(expression as GroupingExpr, level);
        default: PrintUnknown(level);
        }
    }

    void Print(Token token, int level = 0)
    {
        let indent = GetIndentation(.. scope String(), level);

        Console.WriteLine(scope $"{indent}{token.Literal}");
    }

    void PrintBinary(BinaryExpr expr, int level)
    {
        let indent = GetIndentation(.. scope String(), level);

        Console.WriteLine(scope $"{indent}<Binary:");
        Print(expr.Left, level + 1);
        Print(expr.Operator, level + 1);
        Print(expr.Right, level + 1);
        Console.WriteLine(scope $"{indent}/Binary>");
    }

    void PrintLiteral(LiteralExpr expr, int level)
    {
        let indent = GetIndentation(.. scope String(), level);
        Console.WriteLine(scope $"{indent}{expr.Literal}");
    }

    void PrintUnary(UnaryExpr expr, int level)
    {
        let indent = GetIndentation(.. scope String(), level);
        Console.WriteLine(scope $"{indent}<Unary:");
        Print(expr.Operator, level + 1);
        Print(expr.Right, level + 1);
        Console.WriteLine(scope $"{indent}/Unary>");
    }

    void PrintGrouping(GroupingExpr expr, int level)
    {
        let indent = GetIndentation(.. scope String(), level);

        Console.WriteLine(scope $"{indent}<Grouping:");
        Print(expr.Expr, level + 1);
        Console.WriteLine(scope $"{indent}/Grouping>");
    }

    void PrintUnknown(int level)
    {
        let indent = GetIndentation(.. scope String(), level);

        Console.WriteLine(scope $"{indent}<Unknown>");
    }

    void GetIndentation(String indent, int level)
    {
        indent.Clear();

        for (let _ in 0 ... level)
        {
            indent.Append("  ");
        }
    }
}