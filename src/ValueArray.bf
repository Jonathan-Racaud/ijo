using System;
using System.Collections;
namespace ijo
{
	struct ValueArray: IDisposable
	{
		public int Count => Values.Count;
		public int Capacity => Values.Capacity;

		public List<ijoValue> Values { get; private set mut; } = new .();

		public void Add(ijoValue value)
		{
			Values.Add(value);
		}

		public void Dispose()
		{
			delete Values;
		}
	}
}