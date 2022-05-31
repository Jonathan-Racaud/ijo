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
        case Base;
        case This;
        case True;
        case False;
        case While;
        case For;
        case If;
        case Else;
        case And;
        case Or;
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
            case .Star: return "*";

            // One or two character tokens
            case .Bang: return "!";
            case .BangEqual: return "!=";
            case .Equal: return "=";
            case .EqualEqual: return "==";
            case .Greater: return ">";
            case .GreaterEqual: return ">=";
            case .Less: return "<";
            case .LessEqual: return "<=";

            // Literals
            case .Base: return "base";
            case .This: return "this";
            case .True: return "true";
            case .False: return "false";
            case .While: return "while";
            case .For: return "for";
            case .If: return "if";
            case .Else: return "else";
            case .And: return "and";
            case .Or: return "or";
            case .Return: return "return";
            /*case .Type: return "type";
            case .Functions: return "functions";
            case .Interface: return "interface";
            case .Operators: return "operators";
            case .Func: return "func";
            case .Var: return "var";
            case .Let: return "let";
            case .Assume: return "assume";
            case .Of: return "of";
            case .Import: return "import";*/
            case .Error: return "error";
            case .EOF: return "\0";
            default: return "";
            }
        }
    }
}