namespace ijo;

class ijoProgram
{
	private ExprList expressions;
	public ExprList Expressions { get => expressions; }

	public this(ExprList expressions)
	{
		this.expressions = expressions;
	}

	public ~this()
	{
		for (let expr in expressions)
		{
			expr.Dispose();
		}
		delete expressions;
	}
}