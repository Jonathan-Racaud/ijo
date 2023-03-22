using System;
using System.Collections;
using System.IO;
using ijoLang.AST;

namespace ijoLang.Emitters;

#if BYTECODE_EMITTER_ENABLED

class ByteCodeGenerator: Emitter
{
    Scope Scope;

    public this(Scope env)
    {
        this.Scope = env;
    }

    /*public Result<void> Emit(Stream stream, List<Expression> expressions)
    {
        for (var expr in expressions)
        {
            if (Emit(stream, expr) case .Err) return .Err;
        }

        /*stream.Write(OpCode.Return);*/

        return .Ok;
    }*/

    Result<void> Emit(Stream stream, Expression expression)
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
        default: return .Err;
        }
        return .Ok;
    }

    Result<void> Emit(Stream stream, BinaryExpr expr)
    {
        Emit(stream, expr.Left);
        Emit(stream, expr.Right);
        GenerateOperation(expr.Operator);

        return .Ok;
    }

    Result<void> Emit(Stream stream, GroupingExpr expr)
    {
        Emit(stream, expr.Expr);

        return .Ok;
    }

    Result<void> Emit(Stream stream, UnaryExpr expr)
    {
        Emit(stream, expr.Right);
        GenerateUnaryOperation(stream, expr.Operator);

        return .Ok;
    }

    Result<void> Emit(Stream stream, LiteralExpr expr)
    {
        switch (expr.Type)
        {
        case .Integer:
            let val = int.Parse(expr.Literal).Value;
            stream.Write(OpCode.ConstantI);
            stream.Write(1);
            stream.Write((uint16)val);

        case .Float:
            let val = double.Parse(expr.Literal).Value;
            stream.Write(OpCode.ConstantD);
            stream.Write(1);
            stream.Write((uint16)val);

        // OP_STRING STR_IDX
        case .String:
            let idx = Scope.DefineString(scope .(expr.Literal));
            stream.Write(OpCode.String);
            stream.Write(idx);

        // OP_SYMBOL SYMBOL_IDX
        case .Symbol:
            let idx = Scope.DefineSymbol(scope .(expr.Literal));
            stream.Write(OpCode.Symbol);
            stream.Write(idx);

        default: return .Err;
        }

        return .Ok;
    }

    Result<void> Emit(Stream stream, PrintExpr expr)
    {
        if (Emit(stream, expr.Expr) case .Err) return .Err;

        stream.Write(OpCode.Print);

        return .Ok;
    }

    Result<void> Emit(Stream stream, VarExpr expr)
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

        if (Emit(stream, expr.Expr) case .Err) return .Err;

        stream.Write(OpCode.VarDef);
        stream.Write((uint16)varIdx);

        return .Ok;
    }

    Result<void> Emit(Stream stream, IdentifierExpr expr)
    {
        if (!Scope.HasVar(expr.Name))
            return .Err;

        let varIdx = Scope.GetVariable(expr.Name);
        stream.Write(OpCode.Identifier);
        stream.Write((uint16)varIdx);

        return .Ok;
    }

    Result<void> Emit(Stream stream, AssignmentExpr expr)
    {
        let varName = (expr.Identifier as IdentifierExpr).Name;
        if (!Scope.HasVar(varName))
            return .Err;

        if (Emit(stream, expr.Assignment) case .Err) return .Err;

        let varIdx = Scope.GetVariable(varName);
        stream.Write(OpCode.VarSet);
        stream.Write((uint16)varIdx);

        return .Ok;
    }

    Result<void> Emit(Stream stream, ConditionExpr expr)
    {
        List<uint16> bodyInstructions = scope .();
        for (let e in expr.Body)
        {
            if (Emit(stream, e, bodyInstructions) case .Err) return .Err;
        }

        if (Emit(stream, expr.Condition) case .Err) return .Err;
        stream.Write(OpCode.IsTrue);
        stream.Write((uint16)code.Count + 2);
        stream.Write((uint16)(code.Count + bodyInstructions.Count) + 1);
        stream.WriteRange(bodyInstructions);

        return .Ok;
    }

    Result<void> Emit(Stream stream, LoopExpr expr)
    {
        if (expr.Initialization != null)
        {
            if (Emit(stream, expr.Initialization) case .Err) return .Err;
        }

        List<uint16> incrementInstructions = scope .();
        if (expr.Increment != null)
        {
            if (Emit(stream, expr.Increment, incrementInstructions) case .Err)
            {
                return .Err;
            }
        }

        List<uint16> bodyInstructions = scope .();
        for (let e in expr.Body)
        {
            if (Emit(stream, e, bodyInstructions) case .Err) return .Err;
        }

        let condPos = (uint16)code.Count;

        // First we add the instructions for the condition computation
        if (Emit(stream, expr.Condition) case .Err) return .Err;

        // If true, then we will jump to the first instruction located at code.Count because
        // it is the first instruction after the condition, which is the start of the body.
        // Otherwise we jump to after the end of both the bodyInstructions + incrementInstructions
        stream.Write(OpCode.IsTrue);
        stream.Write((uint16)code.Count + 2);

        let nextIdxIfNoIncrement = (uint16)(code.Count + bodyInstructions.Count) + 2;

        // +3 because last increment instruction +1 = op jump +1 = jump arg +1 = instruction after all of that.
        let nextIdxIfIncrement = (uint16)(code.Count + bodyInstructions.Count + incrementInstructions.Count) + 3;

        stream.Write(incrementInstructions.IsEmpty ? nextIdxIfNoIncrement : nextIdxIfIncrement);

        stream.WriteRange(bodyInstructions);

        // We directly add the increment instructions after the body as they need to be executed
        // for every iteration
        stream.WriteRange(incrementInstructions);

        // We instruct to jump back to the first instruction to compute the condition
        stream.Write(OpCode.Jump);
        stream.Write(condPos);

        return .Ok;
    }

    Result<void> Emit(Stream stream, FunctionExpr expr)
    {
        List<uint16> code = new .();
        for (uint16 i = 0; i < expr.Parameters.Count; i++)
        {
            var idx = -1;
            if (!Scope.HasString(scope .(expr.Parameters[i])))
            {
                idx = Scope.DefineString(new .(expr.Parameters[i]));
            }
            stream.Write(OpCode.LoadArg);
            // When calling the function, the parameter to be loaded on the stack has to be associated with
            // the name at idx.
            stream.Write((uint16)idx);
        }

        if (Emit(stream, expr.Body) case .Err) return .Err;

        Scope.AddFunc(expr.Name, expr.Parameters.Count, expr.ReturnType);

        return .Ok;
    }

    Result<void> Emit(Stream stream, FunctionCallExpr expr)
    {
        let funcIdx = Scope.GetFuncIdx(expr.Name, expr.Arguments.Count);
        stream.Write(OpCode.Call);
        stream.Write((uint16)funcIdx);

        return .Ok;
    }

    Result<void> GenerateOperation(Token token)
    {
        switch (token.Type)
        {
        case .Plus: stream.Write(OpCode.Add);
        case .Minus: stream.Write(OpCode.Subtract);
        case .Slash: stream.Write(OpCode.Divide);
        case .Star: stream.Write(OpCode.Multiply);
        case .Percent: stream.Write(OpCode.Modulo);
        case .EqualEqual: stream.Write(OpCode.Equal);
        case .BangEqual: stream.Write(OpCode.NotEqual);
        case .Greater: stream.Write(OpCode.Greater);
        case .GreaterEqual: stream.Write(OpCode.GreaterThan);
        case .Less: stream.Write(OpCode.Less);
        case .LessEqual: stream.Write(OpCode.LessThan);
        default: return .Err;
        }

        return .Ok;
    }

    Result<void> GenerateUnaryOperation(Stream stream, Token token)
    {
        switch (token.Type)
        {
        case .Bang: stream.Write(OpCode.Negate);
        case .Minus: stream.Write(OpCode.Opposite);
        default: return .Err;
        }

        return .Ok;
    }
}
#endif