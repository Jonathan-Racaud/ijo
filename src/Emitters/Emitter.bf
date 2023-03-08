using System.Collections;
using System.IO;

using ijoLang.AST;
using ijoLang;
namespace ijoLang.Emitters;

abstract class Emitter
{
    public abstract void Emit(Stream stream, List<Expression> expressions);
    public abstract void Emit(Stream stream, Expression expression);

    protected abstract void Emit(Stream stream, BinaryExpr expression);
    protected abstract void Emit(Stream stream, GroupingExpr expression);
    protected abstract void Emit(Stream stream, UnaryExpr expression);
    protected abstract void Emit(Stream stream, LiteralExpr expression);
    protected abstract void Emit(Stream stream, PrintExpr expression);
    protected abstract void Emit(Stream stream, VarExpr expression);
    protected abstract void Emit(Stream stream, IdentifierExpr expression);
    protected abstract void Emit(Stream stream, ConditionExpr expression);
    protected abstract void Emit(Stream stream, LoopExpr expression);
    protected abstract void Emit(Stream stream, AssignmentExpr expression);
    protected abstract void Emit(Stream stream, FunctionExpr expression);
    protected abstract void Emit(Stream stream, FunctionCallExpr expression);
    protected abstract void Emit(Stream stream, Token token);
}