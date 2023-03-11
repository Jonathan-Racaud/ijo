using System;
using System.Collections;
using System.IO;

using ijoLang;
using ijoLang.AST;

namespace ijoLang.Emitters;

class JSEmitter : Emitter
{
    public String StdOutCall = new .() ~ delete _;
    private bool printing;

    public override void Emit(Stream stream, List<Expression> expressions)
    {
        for (var expr in expressions)
        {
            Emit(stream, expr);
        }
    }

    public override void Emit(Stream stream, Expression expression)
    {
        switch (expression.GetType())
        {
        case typeof(BinaryExpr): Emit(stream, expression as BinaryExpr);
        case typeof(GroupingExpr): Emit(stream, expression as GroupingExpr);
        case typeof(UnaryExpr): Emit(stream, expression as UnaryExpr);
        case typeof(LiteralExpr): Emit(stream, expression as LiteralExpr);
        case typeof(PrintExpr): Emit(stream, expression as PrintExpr);
        case typeof(VarExpr): Emit(stream, expression as VarExpr);
        case typeof(IdentifierExpr): Emit(stream, expression as IdentifierExpr);
        case typeof(ConditionExpr): Emit(stream, expression as ConditionExpr);
        case typeof(LoopExpr): Emit(stream, expression as LoopExpr);
        case typeof(AssignmentExpr): Emit(stream, expression as AssignmentExpr);
        case typeof(FunctionExpr): Emit(stream, expression as FunctionExpr);
        case typeof(FunctionCallExpr): Emit(stream, expression as FunctionCallExpr);
        default: return;
        }
    }

    protected override void Emit(Stream stream, BinaryExpr expression)
    {
        Emit(stream, expression.Left);
        stream.Write(" ");
        Emit(stream, expression.Operator);
        stream.Write(" ");
        Emit(stream, expression.Right);
    }

    protected override void Emit(Stream stream, GroupingExpr expression)
    {
        stream.Write("(");
        Emit(stream, expression.Expr);
        stream.Write(")");
    }

    protected override void Emit(Stream stream, UnaryExpr expression)
    {
        Emit(stream, expression.Operator);
        Emit(stream, expression.Right);
    }

    protected override void Emit(Stream stream, LiteralExpr expression)
    {
        switch (expression.Type)
        {
        case .Integer, .Float:
            stream.Write(expression.Literal);

            if (printing)
            {
                stream.Write(".toString()");
            }
        case .String:
            stream.Write(expression.Literal.QuoteString(.. scope .()));
        default: return;
        }
    }

    protected override void Emit(Stream stream, PrintExpr expression)
    {
        printing = true;
        stream.Write(scope $"{StdOutCall}(");
        Emit(stream, expression.Expr);
    	stream.Write("); ");
        printing = false;
    }

    protected override void Emit(Stream stream, VarExpr expression)
    {
        stream.Write("var ");
        stream.Write(expression.Name);
        stream.Write(" = ");
        Emit(stream, expression.Expr);
        stream.Write("; ");
    }

    protected override void Emit(Stream stream, IdentifierExpr expression)
    {
        stream.Write(expression.Name);

        if (printing)
        {
            stream.Write(".toString()");
        }
    }

    protected override void Emit(Stream stream, ConditionExpr expression)
    {
        stream.Write("if (");
        Emit(stream, expression.Condition);
        stream.Write(") {");
        for (let instruction in expression.Body)
        {
            Emit(stream, instruction);
        }
        stream.Write("} ");
    }

    protected override void Emit(Stream stream, LoopExpr expression)
    {
        stream.Write("for (");

        if (expression.Initialization != null)
        {
            Emit(stream, expression.Initialization);
            stream.Write(";");
        }

        if (expression.Condition != null)
        {
            Emit(stream, expression.Condition);
            stream.Write(";");
        }

        if (expression.Increment!= null)
        {
            Emit(stream, expression.Condition);
        }

        stream.Write(") {\n");

        for (let instruction in expression.Body)
        {
            Emit(stream, instruction);
            stream.Write("\n");
        }

        stream.Write("} ");
    }

    protected override void Emit(Stream stream, AssignmentExpr expression)
    {
        Emit(stream, expression.Identifier);
        stream.Write(" = ");

        Emit(stream, expression.Assignment);
        stream.Write("; ");
    }

    protected override void Emit(Stream stream, FunctionExpr expression)
    {
        stream.Write("function ");
        stream.Write(expression.Name);
        stream.Write("(");

        for (let param in expression.Parameters)
        {
            stream.Write(param);
            stream.Write(",");
        }

        stream.Seek(-1, .Relative);
        stream.Write(") {\n");

        for (let instruction in expression.Body)
        {
            Emit(stream, instruction);
        }

        stream.Write("} ");
    }

    protected override void Emit(Stream stream, FunctionCallExpr expression)
    {
        stream.Write(expression.Name);
        stream.Write("(");

        for (let arg in expression.Arguments)
        {
            Emit(stream, arg);
            stream.Write(",");
        }

        stream.Write("); ");
    }

    protected override void Emit(Stream stream, Token token)
    {
        stream.Write(token.Literal);
    }
}