using System;
namespace ijo
{
    struct Token
    {
        public TokenType Type;
        public char8* Start;
        public int Length;
        public int Line;

        public this(TokenType type, char8* start, int length, int line)
        {
            Type = type;
            Start = start;
            Length = length;
            Line = line;
        }
    }

    enum TokenType
    {
        // Single character tokens
        case LeftParen;
        case RightParen;
        case LeftBrace;
        case RightBrace;
        case Comma;
        case Colon;
        case Dot;
        case Minus;
        case Plus;
        case Semicolon;
        case Slash;
        case Star;
        case Percent;
        case Var;
        case Question;
        case Underscore;
        case Tilde;
        case Pipe;

        // One or two character tokens
        case Bang;
        case BangEqual;
        case Equal;
        case EqualEqual;
        case Greater;
        case GreaterEqual;
        case Less;
        case LessEqual;

        // Controls
        case If;
        case Switch;
        case While;
        case Return;
        case Break;
        case Function;
        case Type;

        // Literals
        case Identifier;
        case String;
        case Symbol;
        case Number;
        case Error;
        case EOF;

        public static operator StringView(Self value)
        {
            switch (value)
            {
            // Single character tokens
            case .LeftParen: return "(";
            case .RightParen: return ")";
            case .LeftBrace: return "{";
            case .RightBrace: return "}";
            case .Comma: return ",";
            case .Dot: return ".";
            case .Plus: return "+";
            case .Semicolon: return ";";
            case .Colon: return ":";
            case .Slash: return "/";
            case .Percent: return "%";
            case .Star: return "*";
            case .Var: return "$";
            case .Underscore: return "_";
            case .Pipe: return "|";

            // One or two character tokens
            case .Bang: return "!";
            case .BangEqual: return "!=";
            case .Equal: return "=";
            case .EqualEqual: return "==";
            case .Greater: return ">";
            case .GreaterEqual: return ">=";
            case .Less: return "<";
            case .LessEqual: return "<=";
            case .Question: return "?";
            case .Tilde: return "~";
            case .Minus: return "-";

            case .If: return "?(";
            case .While: return "~(";
            case .Break: return "<-";
            case .Return: return "->";
            case .Function: return "(){}";
            case .Type: return "<>";
            case .Symbol: return ":";

            // Others
            case .Error: return "error";
            case .EOF: return "\0";
            default: return "";
            }
        }
    }
}