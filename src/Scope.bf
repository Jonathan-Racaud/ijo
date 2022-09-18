using System;
using System.Collections;
namespace ijo;

struct VarDefinition : IDisposable
{
    public String Name = new .();
    public Value Value;

    public this(StringView name, Value value)
    {
        Name.Set(name);
        Value = value;
    }

    public void Dispose()
    {
        delete Name;
    }
}

static
{
    public static VarDefinition UndefinedVarDef = .("undefined", .Undefined) ~ _.Dispose();
}

class VarList : ICollection<VarDefinition>
{
    List<VarDefinition> list = new .() ~ DeleteContainerAndDisposeItems!(_);

    public int Count => list.Count;

    public void Add(VarDefinition item)
    {
        list.Add(item);
    }

    public void Clear()
    {
        list.Clear();
    }

    public bool Contains(VarDefinition item)
    {
        for (var elem in list)
        {
            if (elem.Name == item.Name)
                return true;
        }

        return false;
    }

    public bool Contains(StringView name)
    {
        for (var elem in list)
        {
            if (elem.Name == name)
                return true;
        }

        return false;
    }

    public void CopyTo(Span<VarDefinition> span)
    {
    }

    public bool Remove(VarDefinition item)
    {
        if (Contains(item))
        {
            list.Remove(item);
            return true;
        }

        return false;
    }

    public VarDefinition this[StringView name]
    {
        get
        {
            for (var elem in list)
            {
                if (elem.Name == name)
                    return elem;
            }

            return UndefinedVarDef;
        }

        set
        {
            for (var elem in list)
            {
                if (elem.Name == name)
                {
                    elem = value;
                    return;
                }
            }
        }
    }

    public int IndexOf(StringView name)
    {
        for (var i = 0; i < list.Count; i++)
        {
            if (list[i].Name == name)
                return i;
        }

        return -1;
    }

    public void Set(int index, Value value)
    {
        list[index].Value = value;
    }

    public Value Get(int index)
    {
        return list[index].Value;
    }
}

class Scope
{
    private Scope parent;

    private Dictionary<StringView, Value> constants = new .();
    /*private Dictionary<StringView, Value> variables = new .();*/

    private VarList variables = new .();

    // We want every scope to share the same symbols and strings
    private List<String> symbols;
    private List<String> strings;

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

        delete variables;

        if (parent == null)
        {
            DeleteContainerAndItems!(strings);
            DeleteContainerAndItems!(symbols);
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

        return variables.Contains(name);
    }

    public bool HasSymbol(String name)
    {
        return symbols.Contains(name);
    }

    public bool HasString(String name)
    {
        return strings.Contains(name);
    }

    public bool DefineConst(StringView name, Value value)
    {
        if (HasConst(name))
            return false;

        return constants.TryAdd(name, value);
    }

    public uint16 DefineSymbol(String name)
    {
        if (HasSymbol(name))
            return (uint16)symbols.IndexOf(name);

        symbols.Add(new .(name));
        return (uint16)symbols.Count - 1;
    }

    public uint16 DefineString(String name)
    {
        if (HasString(name))
            return (uint16)strings.IndexOf(name);

        strings.Add(new .(name));
        return (uint16)strings.Count - 1;
    }

    public bool SetVar(StringView name, Value value)
    {
        if (parent.HasVar(name))
            return parent.SetVar(name, value);

        if (variables.Contains(name))
        {
            variables[name] = .(name, value);
        }

        variables.Add(.(name, value));
        return true;
    }

    public void SetVar(int index, Value value)
    {
        variables.Set(index, value);
    }

    public int AddVar(StringView name)
    {
        variables.Add(.(name, .Undefined));
        return variables.Count - 1;
    }

    public String GetString(uint16 idx)
    {
        return strings[idx];
    }

    public String GetSymbol(uint16 idx)
    {
        return symbols[idx];
    }

    public Value GetConstant(StringView name)
    {
        return constants[name];
    }

    public int GetVariable(StringView name)
    {
        if (parent != null && parent.HasVar(name))
        {
            return parent.GetVariable(name);
        }

        if (variables.Contains(name))
        {
            return variables.IndexOf(name);
        }

        return -1;
    }

    public Value GetVarValue(int index)
    {
        return variables.Get(index);
    }
}