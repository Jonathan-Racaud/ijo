using System;
using System.Collections;
using ijo.AST;
namespace ijo;

class ByteCodeGenerator
{
    Scope Scope;

    public this(Scope env)
    {
        this.Scope = env;
    }

    public Result<void> Generate(List<Expression> expressions, List<uint16> code)
    {
        for (var expr in expressions)
        {
            if (Generate(expr, code) case .Err) return .Err;
        }

        /*code.Add(OpCode.Return);*/

        return .Ok;
    }

    Result<void> Generate(Expression expression, List<uint16> code)
    {
        switch (expression.GetType())
        {
        case typeof(BinaryExpr): Generate(expression as BinaryExpr, code);
        case typeof(GroupingExpr): Generate(expression as GroupingExpr, code);
        case typeof(UnaryExpr): Generate(expression as UnaryExpr, code);
        case typeof(LiteralExpr): Generate(expression as LiteralExpr, code);
        case typeof(PrintExpr): Generate(expression as PrintExpr, code);
        case typeof(VarExpr): Generate(expression as VarExpr, code);
        case typeof(IdentifierExpr): Generate(expression as IdentifierExpr, code);
        default: return .Err;
        }
        return .Ok;
    }

    Result<void> Generate(BinaryExpr expr, List<uint16> code)
    {
        Generate(expr.Left, code);
        Generate(expr.Right, code);
        GenerateOperation(expr.Operator, code);

        return .Ok;
    }

    Result<void> Generate(GroupingExpr expr, List<uint16> code)
    {
        Generate(expr.Expr, code);

        return .Ok;
    }

    Result<void> Generate(UnaryExpr expr, List<uint16> code)
    {
        Generate(expr.Right, code);
        GenerateUnaryOperation(expr.Operator, code);

        return .Ok;
    }

    Result<void> Generate(LiteralExpr expr, List<uint16> code)
    {
        switch (expr.Type)
        {
        case .Integer:
            let val = int.Parse(expr.Literal).Value;
            code.Add(OpCode.ConstantI);
            code.Add(1);
            code.Add((uint16)val);

        case .Float:
            let val = double.Parse(expr.Literal).Value;
            code.Add(OpCode.ConstantD);
            code.Add(1);
            code.Add((uint16)val);

        // OP_STRING STR_IDX
        case .String:
            let idx = Scope.DefineString(scope .(expr.Literal));
            code.Add(OpCode.String);
            code.Add(idx);

        // OP_SYMBOL SYMBOL_IDX
        case .Symbol:
            let idx = Scope.DefineSymbol(scope .(expr.Literal));
            code.Add(OpCode.Symbol);
            code.Add(idx);

        default: return .Err;
        }

        return .Ok;
    }

    Result<void> Generate(PrintExpr expr, List<uint16> code)
    {
        if (Generate(expr.Expr, code) case .Err) return .Err;

        code.Add(OpCode.Print);

        return .Ok;
    }

    Result<void> Generate(VarExpr expr, List<uint16> code)
    {
        var varIdx = -1;
        if (Scope.HasVar(expr.Name))
        {
            varIdx = Scope.GetVariable(expr.Name);
        }
        else
        {
            varIdx = Scope.AddVar(expr.Name);
        }

        if (Generate(expr.Expr, code) case .Err) return .Err;

        code.Add(OpCode.VarDef);
        code.Add((uint16)varIdx);

        return .Ok;
    }

    Result<void> Generate(IdentifierExpr expr, List<uint16> code)
    {
        if (!Scope.HasVar(expr.Name))
            return .Err;

        let varIdx = Scope.GetVariable(expr.Name);
        code.Add(OpCode.Identifier);
        code.Add((uint16)varIdx);

        return .Ok;
    }

    Result<void> GenerateOperation(Token token, List<uint16> code)
    {
        switch (token.Type)
        {
        case .Plus: code.Add(OpCode.Add);
        case .Minus: code.Add(OpCode.Subtract);
        case .Slash: code.Add(OpCode.Divide);
        case .Star: code.Add(OpCode.Multiply);
        case .Percent: code.Add(OpCode.Modulo);
        case .EqualEqual: code.Add(OpCode.Equal);
        case .BangEqual: code.Add(OpCode.NotEqual);
        default: return .Err;
        }

        return .Ok;
    }

    Result<void> GenerateUnaryOperation(Token token, List<uint16> code)
    {
        switch (token.Type)
        {
        case .Bang: code.Add(OpCode.Negate);
        case .Minus: code.Add(OpCode.Opposite);
        default: return .Err;
        }

        return .Ok;
    }
}