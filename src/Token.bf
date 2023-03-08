using System;
namespace ijoLang;

struct Token : IDisposable
{
    public TokenType Type;
    public StringView Literal = .();
    public String Origin;
    public int Line;
    public int Column;

    public void PrettyPrint()
    {
        Type.PrettyPrint();
    }

    public void Dispose()
    {
        if (Type == .String && Origin != null)
            delete Origin;
    }
}

enum TokenType : int
{
    // Single character tokens
    case LeftParen;
    case RightParen;
    case LeftBrace;
    case RightBrace;
    case LeftBracket;
    case RightBracket;
    case Comma;
    case Colon;
    case Dot;
    case Minus;
    case Plus;
    case Semicolon;
    case NewLine;
    case Slash;
    case BackSlash;
    case Star;
    case Percent;
    case Var;
    case Const;
    case Question;
    case Underscore;
    case Tilde;
    case Pipe;

    // One or two character tokens
    case And;
    case Bang;
    case BangEqual;
    case Equal;
    case EqualEqual;
    case Greater;
    case GreaterEqual;
    case Less;
    case LessEqual;
    case Or;
    case Print;
    case Read;
    case Import;
    case StartModule;
    case EndModule;

    // Controls
    case Condition;
    case Switch;
    case Loop;
    case Return;
    case Break;
    case Function;
    case Struct;
    case Enum;
    case Map;
    case Array;

    // Literals
    case Identifier;
    case String;
    case Symbol;
    case Integer;
    case Float;
    case This;
    case Base;
    case Undefined;
    case True;
    case False;
    case Error;
    case EOF;

    case __Total;

    public void PrettyPrint()
    {
        switch (this)
        {
        case .And: Console.Write("&&");
        case .Equal: Console.Write("=");
        case .EqualEqual: Console.Write("==");
        case .BangEqual: Console.Write("!=");
        case .Greater: Console.Write(">");
        case .GreaterEqual: Console.Write(">=");
        case .Less: Console.Write("<");
        case .LessEqual: Console.Write("<=");
        case .Minus: Console.Write("-");
        case .Bang: Console.Write("!");
        case .Slash: Console.Write("/");
        case .Star: Console.Write("*");
        case .Plus: Console.Write("+");
        default: Console.Write("To be represented");
        }
    }
}