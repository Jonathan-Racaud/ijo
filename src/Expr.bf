using System;

namespace BLox
{
    public abstract class Expr
    {
        public interface Visitor
        {
            void VisitBinaryExpr(Binary expr);
            void VisitGroupingExpr(Grouping expr);
            void VisitLiteralExpr(Literal expr);
            void VisitUnaryExpr(Unary expr);
            void VisitVariableExpr(Variable expr);
            void VisitAssignExpr(Assign expr);
        }

        public interface Visitor<T>: Visitor
        {
            public T Result { get; };
        }
        // Virtual/Abstract generic are not yet supported
        public abstract void Accept(Visitor visitor);
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

    public class Variable: Expr
    {
        public Token name ;

        public this(Token name)
        {
            this.name = name;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override void Accept(Visitor visitor)
        {
            visitor.VisitVariableExpr(this);
        }
    }

    public class Assign: Expr
    {
        public Token name ;
        public Expr value ~ delete _;

        public this(Token name, Expr value)
        {
            this.name = name;
            this.value = value;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override void Accept(Visitor visitor)
        {
            visitor.VisitAssignExpr(this);
        }
    }
}