using System.Collections;
using System.IO;

using ijoLang.AST;
using ijoLang;

namespace ijoLang.Emitters;

class CEmitter : Emitter
{
    public override void Emit(Stream stream, List<Expression> expressions)
    {
        stream.Write("#include <stdio.h>\n\n");
        stream.Write("int main(int argc, char** argv)\n");
        stream.Write("{\n");

        for (var expr in expressions)
        {
            Emit(stream, expr);
        }

        stream.Write("  return 0;");
        stream.Write("}\n");
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
        Emit(stream, expression.Right);
        Emit(stream, expression.Operator);
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
        case .String:
            stream.Write("\"");
            stream.Write(expression.Literal);
            stream.Write("\"");
        default: return;
        }
    }
 
    protected override void Emit(Stream stream, PrintExpr expression)
    {
        stream.Write("printf(");
        Emit(stream, expression.Expr);
		stream.Write(");");
    }
 
    protected override void Emit(Stream stream, VarExpr expression)
    {
        var canEmit = true;

        switch (expression.Expr.GetType())
        {
        case typeof(LiteralExpr):
            let literal = (expression.Expr as LiteralExpr);

            switch (literal.Type)
            {
            case .Integer:
                stream.Write("int ");
            case .Float:
                stream.Write("float ");
            case .String:
                stream.Write(scope $"char[{literal.Literal.Length}] ");
            default:
                canEmit = false;
				break;
            }
        default:
            canEmit = false;
			break;
        }

        if (!canEmit)
            return;

        stream.Write(expression.Name);
        stream.Write(" = ");
        Emit(stream, expression.Expr);
        stream.Write(";");
    }
 
    protected override void Emit(Stream stream, IdentifierExpr expression)
    {
        stream.Write(expression.Name);
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
        stream.Write("}");
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

        stream.Write("}");
    }
 
    protected override void Emit(Stream stream, AssignmentExpr expression)
    {
        Emit(stream, expression.Identifier);
        stream.Write(" = ");

        Emit(stream, expression.Assignment);
        stream.Write(";");
    }
 
    protected override void Emit(Stream stream, FunctionExpr expression)
    {
        switch (expression.ReturnType)
        {
        case .Integer:
            stream.Write("int ");
        case .Double:
            stream.Write("float ");
        case .Bool:
            stream.Write("int ");
        case .String:
            stream.Write("char* ");
        default:
            stream.Write("void ");
        }

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

        stream.Write("}");
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

        stream.Write(");");
    }

    protected override void Emit(Stream stream, Token token)
    {
        stream.Write(token.Literal);
    }
}