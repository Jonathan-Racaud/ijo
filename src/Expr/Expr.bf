using System;
using System.Collections;

namespace ijo.Expr
{
    public abstract class Expr
    {
        // Virtual/Abstract generic are not yet supported
        public abstract Result<Variant> Accept(Visitor visitor);
    }


    public class BinaryExpr: Expr
    {
        public Expr left  ~ delete _;
        public Token op  ;
        public Expr right  ~ delete _;
        public String CurrentStr = new .() ~ delete _;

        public this(Expr left, Token op, Expr right)
        {
            this.left = left;
            this.op = op;
            this.right = right;
        }

        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitBinaryExpr(this);
        }
    }

    public class CallExpr: Expr
    {
        public Expr callee  ~ delete _;
        public Token paren  ;
        public List<Expr> arguments  ~ delete _;

        public this(Expr callee, Token paren, List<Expr> arguments)
        {
            this.callee = callee;
            this.paren = paren;
            this.arguments = arguments;
        }

        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitCallExpr(this);
        }
    }

    public class GroupingExpr: Expr
    {
        public Expr expression  ~ delete _;

        public this(Expr expression)
        {
            this.expression = expression;
        }

        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitGroupingExpr(this);
        }
    }

    public class LiteralExpr: Expr
    {
        public Variant value  ~ value.Dispose();

        public this(Variant value)
        {
            this.value = value;
        }

        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitLiteralExpr(this);
        }
    }

    public class UnaryExpr: Expr
    {
        public Token op  ;
        public Expr right  ~ delete _;

        public this(Token op, Expr right)
        {
            this.op = op;
            this.right = right;
        }

        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitUnaryExpr(this);
        }
    }

    public class LogicalExpr: Expr
    {
        public Expr left  ~ delete _;
        public Token op  ;
        public Expr right  ~ delete _;

        public this(Expr left, Token op, Expr right)
        {
            this.left = left;
            this.op = op;
            this.right = right;
        }

        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitLogicalExpr(this);
        }
    }

    public class VariableExpr: Expr
    {
        public Token name  ;

        public this(Token name)
        {
            this.name = name;
        }

        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitVariableExpr(this);
        }
    }

    public class AssignmentExpr: Expr
    {
        public Token name  ;
        public Expr value  ~ delete _;

        public this(Token name, Expr value)
        {
            this.name = name;
            this.value = value;
        }

        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitAssignmentExpr(this);
        }
    }
}