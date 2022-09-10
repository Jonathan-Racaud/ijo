using System;
using System.Collections;
namespace ijo;

class Scope
{
    private Scope parent;

    private Dictionary<StringView, Value> constants = new .();
    private Dictionary<StringView, Value> variables = new .();
    private List<StringView> symbols = new .() ~ delete _;
    private List<StringView> strings = new .() ~ delete _;

    public this(Scope parent = null)
    {
        this.parent = parent;
    }

    public ~this()
    {
        for (let v in constants.Values)
        {
            v.Dispose();
        }

        for (let v in variables.Values)
        {
            v.Dispose();
        }
    }

    public bool HasConst(StringView name)
    {
        if (parent != null && parent.HasConst(name))
            return true;

        return constants.ContainsKey(name);
    }

    public bool HasVar(StringView name)
    {
        if (parent != null && parent.HasVar(name))
            return true;

        return variables.ContainsKey(name);
    }

    public bool HasSymbol(StringView name)
    {
        if (parent != null && parent.HasSymbol(name))
            return true;

        return symbols.Contains(name);
    }

    public bool HasString(StringView name)
    {
        if (parent != null && parent.HasString(name))
            return true;

        return strings.Contains(name);
    }

    public bool DefineConst(StringView name, Value value)
    {
        if (HasConst(name))
            return false;

        return constants.TryAdd(name, value);
    }

    public bool DefineSymbol(StringView name)
    {
        if (HasSymbol(name))
            return false;

        symbols.Add(name);
        return true;
    }

    public bool DefineString(StringView name)
    {
        if (HasString(name))
            return false;

        strings.Add(name);
        return true;
    }

    public bool SetVar(StringView name, Value value)
    {
        if (parent.HasVar(name))
            return parent.SetVar(name, value);

        if (variables.ContainsKey(name))
        {
            variables[name] = value;
            return true;
        }

        return variables.TryAdd(name, value);
    }
}