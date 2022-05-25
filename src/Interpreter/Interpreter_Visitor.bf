using System;
using System.Collections;
using ijo.Expr;
using ijo.Mixins;
using ijo.Stmt;
using ijo.Std;

namespace ijo.Interpreter
{
	extension Interpreter: Visitor
	{
		StringView currentArgName;

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
				AddValues!(left, right, val.CurrentStr);
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

			let prevEnv = environment;
			environment = scope ijoEnvironment(environment);

			let args = scope List<Variant>();
			for (let arg in val.arguments)
			{
				let a = Variant.CreateFromVariant(Guard!(Evaluate(arg)));
				args.Add(a);
			}

			let result = func.call(this, args);
			environment = prevEnv;

			for (var arg in args)
				arg.Dispose();

			return result;
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
			let env = scope ijoEnvironment(environment);

			ExecuteBlock(val.Statements, env);

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
			Variant variable = default;

			if (val.initializer != null)
				variable = Guard!(Evaluate(val.initializer));

			environment.Define(val.name.Lexeme, variable, val.mutability.Type == .Let);
			return default;
		}

		public Result<Variant> VisitFunctionStmt(FunctionStmt val)
		{
			let func = new ijoFunction(val);

			environment.DefineFunction(val.name.Lexeme, Variant.Create(func, true));
			return default;
		}
	}
}