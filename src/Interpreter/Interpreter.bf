using System;
using System.Collections;
using ijo.Expr;
using ijo.Mixins;
using ijo.Stmt;
using ijo.Scope;
using ijo.Std;

namespace ijo.Interpreter
{
	class Interpreter
	{
		private Scope environment = new .() ~ delete _;

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

		void Execute(Stmt stmt)
		{
			stmt.Accept(this).IgnoreError();
		}

		void ExecuteBlock(List<Stmt> stmts, Scope env)
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
				(operand.VariantType == typeof(double))
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

	extension Interpreter: Visitor
	{
		public Result<Variant> VisitBinaryExpr(BinaryExpr val)
		{
			let left = Guard!(Evaluate(val.left));
			let right = Guard!(Evaluate(val.right));

			switch (val.op.Type)
			{
			case .Minus:
				if (ValidNumberOperands(val.op, left, right) case .Err) return default;
				if (left.VariantType == typeof(double) && right.VariantType == typeof(double))
					return Variant.Create(left.Get<double>() - right.Get<double>());
				else if (left.VariantType == typeof(int) && right.VariantType == typeof(int))
					return Variant.Create(left.Get<int>() - right.Get<int>());
			case .Slash:
				if (ValidNumberOperands(val.op, left, right) case .Err) return default;
				else if (left.VariantType == typeof(double) && right.VariantType == typeof(double))
					return Variant.Create(left.Get<double>() / right.Get<double>());
				else if (left.VariantType == typeof(int) && right.VariantType == typeof(int))
					return Variant.Create(left.Get<int>() / right.Get<int>());
			case .Star:
				if (ValidNumberOperands(val.op, left, right) case .Err) return default;
				if (left.VariantType == typeof(double) && right.VariantType == typeof(double))
					return Variant.Create(left.Get<double>() * right.Get<double>());
				else if (left.VariantType == typeof(int) && right.VariantType == typeof(int))
					return Variant.Create(left.Get<int>() * right.Get<int>());
			case .Plus:
				if (left.VariantType == typeof(String) && right.VariantType == typeof(String))
					return Variant.Create(new $"{left.Get<String>()}{right.Get<String>()}", true);
				if (left.VariantType == typeof(double) && right.VariantType == typeof(double))
					return Variant.Create(left.Get<double>() + right.Get<double>());
				else if (left.VariantType == typeof(int) && right.VariantType == typeof(int))
					return Variant.Create(left.Get<int>() + right.Get<int>());
			case .Greater:
				if (ValidNumberOperands(val.op, left, right) case .Err) return default;
				if (left.VariantType == typeof(double) && right.VariantType == typeof(double))
					return Variant.Create(left.Get<double>() > right.Get<double>());
				else if (left.VariantType == typeof(int) && right.VariantType == typeof(int))
					return Variant.Create(left.Get<int>() > right.Get<int>());
			case .GreaterEqual:
				if (ValidNumberOperands(val.op, left, right) case .Err) return default; 
				if (left.VariantType == typeof(double) && right.VariantType == typeof(double))
					return Variant.Create(left.Get<double>() >= right.Get<double>());
				else if (left.VariantType == typeof(int) && right.VariantType == typeof(int))
					return Variant.Create(left.Get<int>() >= right.Get<int>());
			case .Less:
				if (ValidNumberOperands(val.op, left, right) case .Err) return default;
				if (left.VariantType == typeof(double) && right.VariantType == typeof(double))
					return Variant.Create(left.Get<double>() < right.Get<double>());
				else if (left.VariantType == typeof(int) && right.VariantType == typeof(int))
					return Variant.Create(left.Get<int>() < right.Get<int>());
			case .LessEqual:
				if (ValidNumberOperands(val.op, left, right) case .Err) return default; 
				if (left.VariantType == typeof(double) && right.VariantType == typeof(double))
					return Variant.Create(left.Get<double>() <= right.Get<double>());
				else if (left.VariantType == typeof(int) && right.VariantType == typeof(int))
					return Variant.Create(left.Get<int>() <= right.Get<int>());
			case .BangEqual:
				return Variant.Create(!IsEqual(left, right));
			case .EqualEqual:
				return Variant.Create(IsEqual(left, right));
			default:
				break;
			}

			return default;
		}

		public Result<Variant> VisitCallExpr(CallExpr val)
		{
			let funcVariant = Guard!(Evaluate(val.callee));

			if (!funcVariant.VariantType.IsSubtypeOf(typeof(ijoCallable)))
				return .Err(InterpretError.CallNonFunction(val.paren.Lexeme));

			let func = funcVariant.Get<ijoCallable>();

			if (func.Arity != val.arguments.Count)
				return .Err(InterpretError.InvalidArgumentCount);

			let args = scope List<Variant>();
			for (let arg in val.arguments)
			{
				let a = Guard!(Evaluate(arg));
				args.Add(a);
			}

			return func.call(environment, args);
		}

		public Result<Variant> VisitGroupingExpr(GroupingExpr val)
		{
			return Guard!(Evaluate(val.expression));
		}

		public Result<Variant> VisitLiteralExpr(LiteralExpr val)
		{
			return val.value;
		}

		public Result<Variant> VisitUnaryExpr(UnaryExpr val)
		{
			let right = Guard!(Evaluate(val.right));

			switch (val.op.Type)
			{
			case .Minus:
				if (ValidNumberOperand(val.op, right) case .Err) return default;

				if (right.VariantType == typeof(int))
					return Variant.Create(-right.Get<int>());

				if (right.VariantType == typeof(double))
					return Variant.Create(-right.Get<double>());
			case .Bang:
				return Variant.Create(!IsTruthy(right));
			default:
				break;
			}

			return Variant.Create<Object>(null, true);
		}

		public Result<Variant> VisitLogicalExpr(LogicalExpr val)
		{
			return default;
		}

		public Result<Variant> VisitVariableExpr(VariableExpr val)
		{
			switch(environment.Get(val.name))
			{
			case .Err(let err):
				return .Err(InterpretError.VariableError(err));
			case .Ok(let value):
				return value;
			}
		}

		public Result<Variant> VisitAssignmentExpr(AssignmentExpr val)
		{
			let result = Guard!(Evaluate(val.value));
			environment.Assign(val.name, result);

			return result;
		}

		public Result<Variant> VisitBlockStmt(BlockStmt val)
		{
			let env = scope Scope(environment);

			ExecuteBlock(val.statements, env);

			return default;
		}

		public Result<Variant> VisitExpressionStmt(ExpressionStmt val)
		{
			return Guard!(Evaluate(val.expression));
		}

		public Result<Variant> VisitIfStmt(IfStmt val)
		{
			let condition = Guard!(Evaluate(val.condition));

			if (IsTruthy(condition))
				Execute(val.thenBranch);
			else
				Execute(val.elseBranch);

			return default;
		}

		public Result<Variant> VisitWhileStmt(WhileStmt val)
		{
			var condition = Guard!(Evaluate(val.condition));

			while (IsTruthy(condition))
			{
				Execute(val.body);
				condition = Guard!(Evaluate(val.condition));
			}

			return default;
		}

		public Result<Variant> VisitVarStmt(VarStmt val)
		{
			var variable = Variant.Create<Object>(null, true);

			if (val.initializer != null)
				variable = Guard!(Evaluate(val.initializer));

			environment.Define(val.name.Lexeme, variable, val.mutability.Type == .Let);
			return default;
		}
	}
}