using System;

namespace ijo.Mixins
{
	static
	{
		public static mixin Guard(bool condition)
		{
			if (!condition)
			{
				return;
			}
		}

		/// Unwrap the result otherwise returns
		public static mixin Guard<TOk>(Result<TOk> result)
		{
			TOk ok;

			switch (result)
			{
			case .Ok(let val):
				ok = val;
			case .Err(let err):
				return .Err(err);
			}

			ok
		}

		/// Unwrap the result otherwise returns
		public static mixin Guard<TOk>(Result<TOk> result, Action action)
		{
			TOk ok;

			switch (result)
			{
			case .Ok(let val):
				ok = val;
			case .Err(let err):
				if (action != null)
					action();
				return .Err(err);
			}

			ok
		}

		/// Unwrap the result otherwise returns
		public static mixin Guard<TOk, TErr>(Result<TOk, TErr> result, Action action)
		{
			TOk ok;

			switch (result)
			{
			case .Ok(let val):
				ok = val;
			case .Err(let err):
				if (action != null)
					action();
				return .Err(err);
			}

			ok
		}

		/// Unwrap the result otherwise returns
		public static mixin Guard<TOk, TErr>(Result<TOk, TErr> result)
		{
			TOk ok;

			switch (result)
			{
			case .Ok(let val):
				ok = val;
			case .Err(let err):
				return .Err(err);
			}

			ok
		}
	}
}