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
        case Dollar;
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

        // Literals
        case Identifier;
        case String;
        case Number;
        case Return;
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
            case .Minus: return "-";
            case .Plus: return "+";
            case .Semicolon: return ";";
            case .Colon: return ":";
            case .Slash: return "/";
            case .Percent: return "%";
            case .Star: return "*";
            case .Dollar: return "$";
            case .Question: return "?";
            case .Underscore: return "_";
            case .Tilde: return "~";
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

            // Others
            case .Error: return "error";
            case .EOF: return "\0";
            default: return "";
            }
        }
    }
}