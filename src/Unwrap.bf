using System;

namespace BLox
{
	static
	{
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

		public static mixin Otherwise(var block)
		{
			(Action) scope [&]() => {}
		}
	}
}