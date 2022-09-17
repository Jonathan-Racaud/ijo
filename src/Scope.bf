using System;
using System.Collections;
namespace ijo;

class Scope
{
    private Scope parent;

    private Dictionary<StringView, Value> constants = new .();
    private Dictionary<StringView, Value> variables = new .();

    // We want every scope to share the same symbols and strings
    private List<StringView> symbols;
    private List<StringView> strings;

    public this(Scope parent = null)
    {
        this.parent = parent;

        if (parent != null)
        {
            symbols = parent.symbols;
            strings = parent.strings;
        }
        else
        {
            symbols = new .();
            strings = new .();
        }
    }

    public ~this()
    {
        for (let v in constants.Values)
        {
            v.Dispose();
        }
        delete constants;

        for (let v in variables.Values)
        {
            v.Dispose();
        }
        delete variables;

        if (parent == null)
        {
            delete symbols;
            delete strings;
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
        return symbols.Contains(name);
    }

    public bool HasString(StringView name)
    {
        return strings.Contains(name);
    }

    public bool DefineConst(StringView name, Value value)
    {
        if (HasConst(name))
            return false;

        return constants.TryAdd(name, value);
    }

    public uint16 DefineSymbol(StringView name)
    {
        if (HasSymbol(name))
            return (uint16)symbols.IndexOf(name);

        symbols.Add(name);
        return (uint16)symbols.Count - 1;
    }

    public uint16 DefineString(StringView name)
    {
        if (HasString(name))
            return (uint16)strings.IndexOf(name);

        strings.Add(name);
        return (uint16)strings.Count - 1;
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

    public StringView GetString(uint16 idx)
    {
        return strings[idx];
    }

    public StringView GetSymbol(uint16 idx)
    {
        return symbols[idx];
    }

    public Value GetConstant(StringView name)
    {
        return constants[name];
    }

    public Value GetVariable(StringView name)
    {
        return variables[name];
    }
}