using System;
using System.Collections;

namespace BLox
{
	public class Interpreter
	{
		public bool _canConsumeResult = false;
		public Variant Result { get; private set; } ~ Result.Dispose();

		public bool HasError => Error != null;
		public Error Error { get; private set; } = null ~ HandledError();

		private BLox.Environment environment = new .() ~ delete _;

		public void Interpret(List<Stmt> statements)
		{
			for (let statement in statements)
			{
				Execute(statement);
				HandledError();
			}
		}

		public void HandledError()
		{
			if (HasError)
			{
				if (Error is RuntimeError)
					Lox.PrintRuntimeError((RuntimeError)Error);
				DeleteAndNullify!(Error);
			}
		}

		public void HandleResult()
		{
			if (_canConsumeResult)
			{
				Lox.PrintResult(Result);
				_canConsumeResult = false;
			}
		}

		private void Execute(Stmt statement)
		{
			statement.Accept(this);
		}

		private void Evaluate(Expr expr)
		{
			expr.Accept(this);
		}

		private Result<void> ValidNumberOperand(Token token, Variant operand)
		{
			if (operand.VariantType == typeof(double)) return .Ok;

			Error = new RuntimeError(token, "Operand must be a number.");
			return .Err;
		}

		private Result<void> ValidNumberOperands(Token token, Variant left, Variant right)
		{
			if (left.VariantType == typeof(double) && right.VariantType == typeof(double)) return .Ok;

			Error = new RuntimeError(token, "Operands must be numbers.");
			return .Err;
		}

		private bool IsTruthy(Variant variant)
		{
			if (!variant.HasValue) return false;
			if (variant.VariantType == typeof(bool)) return variant.Get<bool>();

			return true;
		}

		private bool IsEqual(Variant left, Variant right)
		{
			if (!left.HasValue && !right.HasValue) return true;
			if (!left.HasValue) return false;

			return left == right;
		}
	}

	extension Interpreter: Expr.Visitor<Variant>
	{
		public void VisitUnaryExpr(Unary expr)
		{
			Evaluate(expr.right);

			switch (expr.op.type)
			{
			case .MINUS:
				if (ValidNumberOperand(expr.op, Result) case .Err) return;
				Result = Variant.Create(-Result.Get<double>());
			case .BANG:
				Result = Variant.Create(!IsTruthy(Result));
			default:
				Result = Variant.Create<Object>(null);
			}
		}

		public void VisitBinaryExpr(Binary expr)
		{
			Evaluate(expr.left);
			let left = Variant.CreateFromVariant(Result);

			if (HasError) return;

			Evaluate(expr.right);
			let right = Variant.CreateFromVariant(Result);

			if (HasError) return;

			switch (expr.op.type)
			{
			case .MINUS:
				if (ValidNumberOperands(expr.op, left, right) case .Err) return;
				Result = Variant.Create(left.Get<double>() - right.Get<double>());
			case .SLASH:
				if (ValidNumberOperands(expr.op, left, right) case .Err) return;
				Result = Variant.Create(left.Get<double>() / right.Get<double>());
			case .STAR:
				if (ValidNumberOperands(expr.op, left, right) case .Err) return;
				Result = Variant.Create(left.Get<double>() * right.Get<double>());
			case .PLUS:
				if (left.VariantType == typeof(String) && right.VariantType == typeof(String))
					Result = Variant.Create(new $"{left.Get<String>()}{right.Get<String>()}", true);
				else if (left.VariantType == typeof(double) && right.VariantType == typeof(double))
					Result = Variant.Create(left.Get<double>() + right.Get<double>());
				else
				{
					Error = new RuntimeError(expr.op, "Operands must both be numbers or strings.");
					return;
				}
			case .GREATER:
				if (ValidNumberOperands(expr.op, left, right) case .Err) return;
				Result = Variant.Create(left.Get<double>() > right.Get<double>());
			case .GREATER_EQUAL:
				if (ValidNumberOperands(expr.op, left, right) case .Err) return; 
				Result = Variant.Create(left.Get<double>() >= right.Get<double>());
			case .LESS:
				if (ValidNumberOperands(expr.op, left, right) case .Err) return;
				Result = Variant.Create(left.Get<double>() < right.Get<double>());
			case .LESS_EQUAL:
				if (ValidNumberOperands(expr.op, left, right) case .Err) return; 
				Result = Variant.Create(left.Get<double>() <= right.Get<double>());
			case .BANG_EQUAL:
				Result = Variant.Create(!IsEqual(left, right));
			case .EQUAL_EQUAL:
				Result = Variant.Create(IsEqual(left, right));
			default:
				break;
			}
		}

		public void VisitGroupingExpr(Grouping expr)
		{
			Evaluate(expr.expression);
		}

		public void VisitLiteralExpr(Literal expr)
		{
			Result = Variant.CreateFromVariant(expr.value);
		}

		public void VisitVariableExpr(Variable expr)
		{
			Variant result;
			if (environment.Get(expr.name, out result) case .Err(let err))
			{
				Error = err;
				HandledError();
			}

			Result = Variant.CreateFromVariant(result);
		}

		public void VisitAssignExpr(Assign expr)
		{
			Evaluate(expr.value);
			environment.Assign(expr.name, Result);
		}
	}

	extension Interpreter: Stmt.Visitor
	{
		public void VisitExpressionStmt(Expression stmt)
		{
			Evaluate(stmt.expression);
			_canConsumeResult = true;
		}

		public void VisitPrintStmt(Print stmt)
		{
			Evaluate(stmt.expression);
			Lox.PrintResult(Result);
			_canConsumeResult = false;
		}

		public void VisitVarStmt(Var stmt)
		{
			Result = Variant.Create<Object>(null);
			if (stmt.initializer != null)
			{
				Evaluate(stmt.initializer);
			}

			environment.Define(stmt.name.lexeme, Result);
		}
	}
}