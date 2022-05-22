using System;
using System;
namespace ijo.Interpreter
{
	extension Interpreter
	{
		mixin AddValues(Variant left, Variant right)
		{
			if (left.VariantType == typeof(String) || right.VariantType == typeof(String))
			{
				let l = GetStringViewFromVariant(left);
				let r = GetStringViewFromVariant(right);

				let v = Variant.Create(new $"{l}{r}", true);
				delete l;
				delete r;

				return v;
			}

			if ((left.VariantType == typeof(double) || right.VariantType == typeof(double)) &&
				(left.VariantType != typeof(bool) && right.VariantType != typeof(bool)))
			{
				return Variant.Create(left.Get<double>() + right.Get<double>());
			}

			if ((left.VariantType == typeof(int) && right.VariantType == typeof(int)) &&
				(left.VariantType != typeof(bool) && right.VariantType != typeof(bool)))
			{
				return Variant.Create(left.Get<int>() + right.Get<int>());
			}

			return .Err(InterpretError.InvalidOperation);
		}

		String GetStringViewFromVariant(Variant variant)
		{
			switch (variant.VariantType)
			{
			case typeof(double): return new $"{variant.Get<double>()}";
			case typeof(int): return new $"{variant.Get<int>()}";
			case typeof(bool): return new $"{variant.Get<bool>()}";
			case typeof(String): return new $"{variant.Get<String>()}";
			default: return new $"{variant.Get<Object>()}";
			}
		}
	}
}