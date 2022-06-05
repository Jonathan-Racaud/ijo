namespace ijo
{
    // ijo precedence level from lowest to highest.
    enum Precedence
    {
        case None;
        case Assignment; // =
        case Or; // ||
        case And; // &&
        case Equality; // == !=
        case Comparison; // < > <= >=
        case Term; // + -
        case Factor; // * /
        case Unary; // ! -
        case Call; // . ()
        case Primary;
    }
}