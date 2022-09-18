using System;
using System.Collections;
namespace ijo;

class ByteCodeExecutor
{
    Scope Scope;
    List<Value> Stack = new .();
    int Current = 0;

    public this(Scope env)
    {
        Scope = env;
    }

    public ~this()
    {
        for (let v in Stack)
        {
            v.Dispose();
        }
        delete Stack;
    }

    public void Execute(List<uint16> code)
    {
        Current = 0;
        for (; Current < code.Count;)
        {
            let op = (OpCode)code[Current];

            switch (op)
            {
            case .ConstantI: PushConst(code, .Integer(0));
            case .ConstantD: PushConst(code, .Double(0));
            case .String: PushString(code, .String(""));
            case .Symbol: PushSymbol(code, .String(""));
            case .Opposite: Negate(code);
            case .Add:
                let a = Stack.PopFront();
                let b = Stack.PopFront();
                Stack.AddFront(b + a);
                a.Dispose();
                b.Dispose();
                Current += 1;
            case .Subtract:
                let a = Stack.PopFront();
                let b = Stack.PopFront();
                Stack.AddFront(b - a);
                a.Dispose();
                b.Dispose();
                Current += 1;
            case .Multiply:
                let a = Stack.PopFront();
                let b = Stack.PopFront();
                Stack.AddFront(b * a);
                a.Dispose();
                b.Dispose();
                Current += 1;
            case .Divide:
                let a = Stack.PopFront();
                let b = Stack.PopFront();
                Stack.AddFront(b / a);
                a.Dispose();
                b.Dispose();
                Current += 1;
            case .Modulo:
                let a = Stack.PopFront();
                let b = Stack.PopFront();
                Stack.AddFront(b % a);
                a.Dispose();
                b.Dispose();
                Current += 1;
            case .Equal:
                let a = Stack.PopFront();
                let b = Stack.PopFront();
                Stack.AddFront(b == a);
                a.Dispose();
                b.Dispose();
                Current += 1;
            case .NotEqual:
                let a = Stack.PopFront();
                let b = Stack.PopFront();
                Stack.AddFront(b != a);
                a.Dispose();
                b.Dispose();
                Current += 1;
            case .Greater:
                let a = Stack.PopFront();
                let b = Stack.PopFront();
                Stack.AddFront(b > a);
                a.Dispose();
                b.Dispose();
                Current += 1;
            case .GreaterThan:
                let a = Stack.PopFront();
                let b = Stack.PopFront();
                Stack.AddFront(b >= a);
                a.Dispose();
                b.Dispose();
                Current += 1;
            case .Less:
                let a = Stack.PopFront();
                let b = Stack.PopFront();
                Stack.AddFront(b < a);
                a.Dispose();
                b.Dispose();
                Current += 1;
            case .LessThan:
                let a = Stack.PopFront();
                let b = Stack.PopFront();
                Stack.AddFront(b <= a);
                a.Dispose();
                b.Dispose();
                Current += 1;
            case .VarDef:
                let val = Stack.PopFront();
                let varIdx = code[Current + 1];
                Scope.SetVar(varIdx, val);
                Current += 2;
            case .Identifier:
                let varIdx = code[Current + 1];
                Stack.AddFront(Scope.GetVarValue(varIdx));
                Current += 2;
            case .VarSet:
                let varIdx = code[Current + 1];
                var val = Scope.GetVarValue(varIdx);
                val = Stack.PopFront();
                Scope.SetVar(varIdx, val);
                Current += 2;
            case .IsTrue:
                let val = Stack.PopFront();
                let trueIns = code[Current + 1];
                let falseIns = code[Current + 2];

                Current = val.IsTrue ? trueIns : falseIns;
            case .Jump:
                let idx = code[Current + 1];
                Current = idx;
            case .Print: Print(code);
            default: return;
            }
        }
    }

    void PushConst(List<uint16> code, Value type)
    {
        Value val;

        // For the moment we force only 1 byte for this operation
        // TODO: Handle multiple size bytes.
        //let argCount = code[index + 1];

        switch (type)
        {
        case .Integer: val = .Integer(code[Current + 2]);
        case .Double: val = .Integer(code[Current + 2]);
        default: return;
        }

        Stack.AddFront(val);

        Current += 3;
    }

    void PushString(List<uint16> code, Value type)
    {
        Value val;

        let idx = code[Current + 1];

        val = .String(new .(Scope.GetString(idx)));

        Stack.AddFront(val);

        Current += 2;
    }

    void PushSymbol(List<uint16> code, Value type)
    {
        Value val;

        let idx = code[Current + 1];

        val = .Symbol(Scope.GetSymbol(idx));

        Stack.AddFront(val);

        Current += 2;
    }

    void Negate(List<uint16> code)
    {
        Value val;

        val = Stack.PopFront();
        val = -val;

        Stack.AddFront(val);

        Current += 1;
    }

    void Print(List<uint16> code)
    {
        defer { Current += 1; }

        if (Stack.IsEmpty)
            return;

        let val = Stack.PopFront();
        val.Print();
        val.Dispose();
    }
}