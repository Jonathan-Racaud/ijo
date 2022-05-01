using System;

namespace BLox
{
	public class AstPrinter: Visitor<String>
	{
		public String Result { get; } = new .() ~ delete _;

		// Visitor implementation
		public void VisitBinaryExpr(Binary expr)
		{
			Parenthesize(expr.op.lexeme, expr.left, expr.right);
		}

		public void VisitGroupingExpr(Grouping expr)
		{
			Parenthesize("group", expr.expression);
		}

		public void VisitLiteralExpr(Literal expr)
		{
			if (!expr.value.HasValue) Result.Append("nil");

			switch (expr.value.VariantType)
			{
			case typeof(String):
				Result.Append(expr.value.Get<String>());
			case typeof(double):
				Result.Append(scope $"{expr.value.Get<double>()}");
			case typeof(int):
				Result.Append(scope $"{expr.value.Get<int>()}");
			default:
				Result.Append("UnkownLiteral");
			}
		}

		public void VisitUnaryExpr(Unary expr)
		{
			Parenthesize(expr.op.lexeme, expr.right);
		}

		public void Build(Expr expr)
		{
			expr.Accept(this);
		}

		void Parenthesize(String name, params Expr[] expressions)
		{
			Result.Append(scope $"({name} ");
			
			for (let expr in expressions)
			{
				expr.Accept(this);
			}

			Result.Append(")");
		}
	}
}