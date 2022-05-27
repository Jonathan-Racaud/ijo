using System;
using ijo.Expr;
using ijo.Stmt;

namespace ijo
{
    public interface Visitor
    {
        public Result<Variant> VisitBinaryExpr(BinaryExpr val);
        public Result<Variant> VisitCallExpr(CallExpr val);
        public Result<Variant> VisitGroupingExpr(GroupingExpr val);
        public Result<Variant> VisitLiteralExpr(LiteralExpr val);
        public Result<Variant> VisitUnaryExpr(UnaryExpr val);
        public Result<Variant> VisitLogicalExpr(LogicalExpr val);
        public Result<Variant> VisitVariableExpr(VariableExpr val);
        public Result<Variant> VisitAssignmentExpr(AssignmentExpr val);
        public Result<Variant> VisitBlockStmt(BlockStmt val);
        public Result<Variant> VisitExpressionStmt(ExpressionStmt val);
        public Result<Variant> VisitIfStmt(IfStmt val);
        public Result<Variant> VisitWhileStmt(WhileStmt val);
        public Result<Variant> VisitFunctionStmt(FunctionStmt val);
        public Result<Variant> VisitVarStmt(VarStmt val);
        public Result<Variant> VisitReturnStmt(ReturnStmt val);
    }
}