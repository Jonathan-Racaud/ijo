using System;

namespace BLox
{
    public abstract class Stmt
    {
        public interface Visitor
        {
            void VisitExpressionStmt(Expression stmt);
            void VisitPrintStmt(Print stmt);
        }

        public interface Visitor<T>: Visitor
        {
            public T Result { get; };
        }
        // Virtual/Abstract generic are not yet supported
        public abstract void Accept(Visitor visitor);
    }


    public class Expression: Stmt
    {
        public Expr expression ~ delete _;

        public this(Expr expression)
        {
            this.expression = expression;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override void Accept(Visitor visitor)
        {
            visitor.VisitExpressionStmt(this);
        }
    }

    public class Print: Stmt
    {
        public Expr expression ~ delete _;

        public this(Expr expression)
        {
            this.expression = expression;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override void Accept(Visitor visitor)
        {
            visitor.VisitPrintStmt(this);
        }
    }
}