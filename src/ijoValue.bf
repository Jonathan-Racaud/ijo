namespace ijo
{
	typealias ijoValue = double;
}

namespace System;
extension Double
{
	public void Print()
	{
		Console.Write(scope $"{this}");
	}
}