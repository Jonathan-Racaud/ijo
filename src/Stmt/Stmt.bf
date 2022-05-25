using System;
using System.Collections;
using ijo.Expr;

namespace ijo.Stmt
{
    public abstract class Stmt
    {
        // Virtual/Abstract generic are not yet supported
        public abstract Result<Variant> Accept(Visitor visitor);
    }


    public class BlockStmt: Stmt
    {
        public List<Stmt> Statements ~ DeleteContainerAndItems!(_);

        public this(List<Stmt> statements)
        {
            Statements = statements;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitBlockStmt(this);
        }
    }

    public class ExpressionStmt: Stmt
    {
        public Expr expression ~ delete _;

        public this(Expr expression)
        {
            this.expression = expression;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitExpressionStmt(this);
        }
    }

    public class IfStmt: Stmt
    {
        public Expr condition ~ delete _;
        public Stmt thenBranch ~ delete _;
        public Stmt elseBranch ~ delete _;

        public this(Expr condition, Stmt thenBranch, Stmt elseBranch)
        {
            this.condition = condition;
            this.thenBranch = thenBranch;
            this.elseBranch = elseBranch;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitIfStmt(this);
        }
    }

    public class WhileStmt: Stmt
    {
        public Expr condition ~ delete _;
        public Stmt body ~ delete _;

        public this(Expr condition, Stmt body)
        {
            this.condition = condition;
            this.body = body;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitWhileStmt(this);
        }
    }

    public class FunctionStmt: Stmt
    {
        public Token name ;
        public List<Token> parameters ~ delete _;
        public Stmt body ~ delete _;

        public this(Token name, List<Token> parameters, Stmt body)
        {
            this.name = name;
            this.parameters = parameters;
            this.body = body;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitFunctionStmt(this);
        }
    }

    public class VarStmt: Stmt
    {
        public Token mutability ;
        public Token name ;
        public Expr initializer ~ delete _;

        public this(Token mutability, Token name, Expr initializer)
        {
            this.mutability = mutability;
            this.name = name;
            this.initializer = initializer;
        }

        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.
        public override Result<Variant> Accept(Visitor visitor)
        {
            return visitor.VisitVarStmt(this);
        }
    }
}