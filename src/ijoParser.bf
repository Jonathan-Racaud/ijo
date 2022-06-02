namespace ijo
{
    struct ijoParser
    {
        public Token Current { get; set mut; }
        public Token Previous { get; set mut; }
        public bool HadError { get; set mut; }
        public bool PanicMode { get; set mut; }
    }
}