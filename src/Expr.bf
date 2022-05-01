using System;

namespace BLox
{
    public abstract class Expr
    {
        // Virtual/Abstract generic are not yet supported
        public abstract void Accept(Visitor visitor);
    }

    public interface Visitor
    {
        void VisitUnaryExpr(Unary expr);
        void VisitBinaryExpr(Binary expr);
        void VisitGroupingExpr(Grouping expr);
        void VisitLiteralExpr(Literal expr);
    }

    public interface Visitor<T>: Visitor
    {
        public T Result { get; };
    }

    public class Unary: Expr
    {
        public Token op ;
        public Expr right ~ delete _;

        public this(Token op, Expr right)
        {
            this.op = op;
            this.right = right;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override void Accept(Visitor visitor)
        {
            visitor.VisitUnaryExpr(this);
        }
    }

    public class Binary: Expr
    {
        public Expr left ~ delete _;
        public Token op ;
        public Expr right ~ delete _;

        public this(Expr left, Token op, Expr right)
        {
            this.left = left;
            this.op = op;
            this.right = right;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override void Accept(Visitor visitor)
        {
            visitor.VisitBinaryExpr(this);
        }
    }

    public class Grouping: Expr
    {
        public Expr expression ~ delete _;

        public this(Expr expression)
        {
            this.expression = expression;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override void Accept(Visitor visitor)
        {
            visitor.VisitGroupingExpr(this);
        }
    }

    public class Literal: Expr
    {
        public Variant value ~ value.Dispose();

        public this(Variant value)
        {
            this.value = value;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override void Accept(Visitor visitor)
        {
            visitor.VisitLiteralExpr(this);
        }
    }
}