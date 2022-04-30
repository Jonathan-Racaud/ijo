using System;

namespace BLox
{
    public abstract class Expr {}

    public static class Binary: Expr
    {
        private static Expr left;
        private static Token op;
        private static Expr right;
        public static void Init(Expr left, Token op, Expr right)
        {
            Binary.left = left;
            Binary.op = op;
            Binary.right = right;
        }
    }

    public static class Grouping: Expr
    {
        private static Expr expression;
        public static void Init(Expr expression)
        {
            Grouping.expression = expression;
        }
    }

    public static class Literal: Expr
    {
        private static Variant value;
        public static void Init(Variant value)
        {
            Literal.value = value;
        }
    }

    public static class Unary: Expr
    {
        private static Token op;
        private static Expr expression;
        public static void Init(Token op, Expr expression)
        {
            Unary.op = op;
            Unary.expression = expression;
        }
    }

}