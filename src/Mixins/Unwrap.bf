using System;

namespace ijo.Mixins
{
	static
	{
		public static mixin Unwrap<T>(Result<T> result)
		{
			T ret;

			switch (result)
			{
			case .Err(let err):
				ret = default;
			case .Ok(let val):
				ret = val;
			}

			ret
		}

		public static mixin Unwrap<T>(Result<T> result, Action action)
		{
			T ret;

			switch (result)
			{
			case .Err(let err):
				action();
				ret = default;
			case .Ok(let val):
				ret = val;
			}

			ret
		}

		public static mixin Unwrap<TOk, TErr>(Result<TOk, TErr> result)
		{
			TOk ret;

			switch (result)
			{
			case .Err(let err):
				ret = default;
			case .Ok(let val):
				ret = val;
			}

			ret
		}

		public static mixin Unwrap<TOk, TErr>(Result<TOk, TErr> result, Action action)
		{
			TOk ret;

			switch (result)
			{
			case .Err(let err):
				action();
				ret = default;
			case .Ok(let val):
				ret = val;
			}

			ret
		}
	}
}