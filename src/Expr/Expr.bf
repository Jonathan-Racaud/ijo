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
        public Expr left ~ delete _;
        public Token op ~ delete _;
        public Expr right ~ delete _;

        public this(Expr left, Token op, Expr right)
        {
            this.left = left;
            this.op = new Token(op);
            this.right = right;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitBinaryExpr(this);
        }
    }

    public class CallExpr: Expr
    {
        public Expr callee ~ delete _;
        public Token paren ~ delete _;
        public List<Expr> arguments ~ DeleteContainerAndItems!(_);

        public this(Expr callee, Token paren, List<Expr> arguments)
        {
            this.callee = callee;
            this.paren = new Token(paren);
            this.arguments = arguments;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitCallExpr(this);
        }
    }

    public class GroupingExpr: Expr
    {
        public Expr expression ~ delete _;

        public this(Expr expression)
        {
            this.expression = expression;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitGroupingExpr(this);
        }
    }

    public class LiteralExpr: Expr
    {
        public Variant value;

        public this(Variant value)
        {
            this.value = Variant.CreateFromVariant(value);
        }

		public ~this()
		{
			if (value.OwnsMemory)
				value.Dispose();
		}

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitLiteralExpr(this);
        }
    }

    public class UnaryExpr: Expr
    {
        public Token op ~ delete _;
        public Expr right ~ delete _;

        public this(Token op, Expr right)
        {
            this.op = new Token(op);
            this.right = right;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitUnaryExpr(this);
        }
    }

    public class LogicalExpr: Expr
    {
        public Expr left ~ delete _;
        public Token op ~ delete _;
        public Expr right ~ delete _;

        public this(Expr left, Token op, Expr right)
        {
            this.left = left;
            this.op = new Token(op);
            this.right = right;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitLogicalExpr(this);
        }
    }

    public class VariableExpr: Expr
    {
        public Token name ~ delete _;

        public this(Token name)
        {
            this.name = new Token(name);
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitVariableExpr(this);
        }
    }

    public class AssignmentExpr: Expr
    {
        public Token name ~ delete _;
        public Expr value ~ delete _;

        public this(Token name, Expr value)
        {
            this.name = new Token(name);
            this.value = value;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitAssignmentExpr(this);
        }
    }
}