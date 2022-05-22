using System;
namespace ijo.Mixins
{
	static
	{
		/// Verify that result is Ok, otherwise it run the defined action and returns
		public static mixin Assume<T>(Result<T> result)
		{
			T ret;

			switch (result)
			{
			case .Err(let err):
				return err;
			case .Ok(let val):
				ret = val;
			}

			ret
		}

		/// Verify that result is Ok, otherwise it run the defined action and returns
		public static mixin Assume<T>(Result<T> result, Action action)
		{
			T ret;

			switch (result)
			{
			case .Err(let err):
				return action();
			case .Ok(let val):
				ret = val;
			}

			ret
		}

		/// Verify that result is Ok, otherwise it run the defined action and returns
		public static mixin Assume<TOk, TErr>(Result<TOk, TErr> result)
		{
			TOk ret;

			switch (result)
			{
			case .Err(let err):
				return err;
			case .Ok(let val):
				ret = val;
			}

			ret
		}

		/// Verify that result is Ok, otherwise it run the defined action and returns
		public static mixin Assume<TOk, TErr>(Result<TOk, TErr> result, Action action)
		{
			TOk ret;

			switch (result)
			{
			case .Err(let err):
				return action();
			case .Ok(let val):
				ret = val;
			}

			ret
		}
	}
}