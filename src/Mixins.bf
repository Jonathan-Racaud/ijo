using System;
namespace ijo;

static
{
    /*public static mixin CallOrReturn<TOk>(Result<TOk, int> result)
    {
        if (result case .Err(let err))
            return err;

        result.Value
    }*/

    public static mixin CallOrReturn(var result)
    {
        if (result case .Err(let err))
            return err;

        result.Value
    }
}