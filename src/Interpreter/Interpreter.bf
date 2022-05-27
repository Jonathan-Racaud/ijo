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
				Execute(statement).IgnoreError();
			}
		}

		public Result<Variant> Execute(Stmt stmt)
		{
			if (stmt == null)
				return default;

			switch (stmt.Accept(this))
			{
			case .Ok(let val):
				if (val.HasValue && val.VariantType == typeof(InterpreterFlow))
				{
					switch (val.Get<InterpreterFlow>())
					{
					case .Normal: return default;
					case .Return(let p0): return p0;
					}

				}
			case .Err: return .Err;
			}

			return default;
		}

		public Result<Variant> ExecuteBlock(List<Stmt> stmts, ijoEnvironment env)
		{
			let prevEnv = environment;
			environment = env;

			for (let stmt in stmts)
			{
				switch (Execute(stmt))
				{
				case .Ok(let val):
					if (val.HasValue) return val;
				case .Err: return .Err;
				}
			}

			environment = prevEnv;
			return default;
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