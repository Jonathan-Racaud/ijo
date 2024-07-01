namespace ijo;

static
{
    public static mixin DeleteIfNotNull(var obj)
    {
        if (obj != null)
        {
            delete obj;
        }
    }

    public static mixin ReturnIfFalse(bool val)
    {
        if (!val)
            return false;
    }

    public static mixin ReturnIfTrue(bool val)
    {
        if (val)
            return true;
    }
}