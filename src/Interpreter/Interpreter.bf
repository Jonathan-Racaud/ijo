using System;
using System.Collections;
using ijo.Expr;
using ijo.Mixins;
using ijo.Stmt;
using ijo.Std;

namespace ijo.Interpreter
{
	class Interpreter
	{
		public ijoEnvironment Globals { get; } = new .() ~ delete _;
		private ijoEnvironment environment = Globals;

		public void RegisterFunctions(params IFunctionRegistrer[] registrers)
		{
			for (let registrer in registrers)
			{
				registrer.RegisterFunctions(environment);
			}
		}

		public void Interpret(List<Stmt> statements)
		{
			for (let statement in statements)
			{
				Execute(statement);
			}
		}

		public void Execute(Stmt stmt)
		{
			stmt.Accept(this).IgnoreError();
		}

		public void ExecuteBlock(List<Stmt> stmts, ijoEnvironment env)
		{
			let prevEnv = environment;
			environment = env;

			for (let stmt in stmts)
			{
				Execute(stmt);
			}

			environment = prevEnv;
		}

		Result<Variant, InterpretError> Evaluate(Expr expr)
		{
			if (expr.Accept(this) case .Ok(let val))
				return val;

			return .Err(.CouldNotEvaluate);
		}

		bool IsTruthy(Variant variant)
		{
			if (!variant.HasValue) return false;
			if (variant.VariantType == typeof(bool)) return variant.Get<bool>();

			return true;
		}

		bool IsEqual(Variant left, Variant right)
		{
			if (!left.HasValue && !right.HasValue) return true;
			if (!left.HasValue) return false;

			return left == right;
		}

		private Result<void, InterpretError> ValidNumberOperand(Token token, Variant operand)
		{
			if (
				(operand.VariantType == typeof(double)) ||
				(operand.VariantType == typeof(int))
				) return .Ok;

			return .Err(.OperandMustBeANumber(token));
		}

		private Result<void, InterpretError> ValidNumberOperands(Token token, Variant left, Variant right)
		{
			if (
				(left.VariantType == typeof(double) && right.VariantType == typeof(double)) ||
				(left.VariantType == typeof(int) && right.VariantType == typeof(int))
				) return .Ok;

			return .Err(.OperandsMustBeNumbers(token));
		}
	}
}