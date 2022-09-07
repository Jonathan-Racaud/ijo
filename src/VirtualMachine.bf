using System;
using System.Collections;
using ijo.AST;
namespace ijo;

class VirtualMachine
{
    private Scanner Scanner = new .() ~ delete _;
    private Parser Parser = new .() ~ delete _;
    private ByteCodeGenerator CodeGenerator = new .() ~ delete _;

#if DEBUG_AST
    private AstPrinter AstPrinter = new .() ~ delete _;
#endif

#if DEBUG_BYTE_CODE
    private ByteCodePrinter BCodePrinter = new .() ~ delete _;
#endif

    typealias TokenList = List<Token>;
    typealias ExpressionList = List<Expression>;
    typealias ByteCodeList = List<uint16>;

    public int Run(String source)
    {
        let tokens = CallOrReturn!(Scan(source));
        let expressions = CallOrReturn!(Parse(tokens));

#if DEBUG_AST
        AstPrinter.Print(expressions);
#endif

        CallOrReturn!(StaticAnalysis(expressions));

        let code = CallOrReturn!(GetByteCode(expressions));

        defer
        {
            code.Clear();
            ClearAndDeleteItems!(expressions);
            tokens.Clear();

            delete code;
            delete expressions;
            delete tokens;
        }

#if DEBUG_BYTE_CODE
        BCodePrinter.Print(code);
#endif

        return Execute(code);
    }

    Result<TokenList, int> Scan(String source)
    {
        List<Token> tokens = new .();

        if (Scanner.Scan(source, tokens) case .Err)
        {
            delete tokens;
            return .Err(Exit.Software);
        }

        return tokens;
    }

    Result<ExpressionList, int> Parse(TokenList tokens)
    {
        List<Expression> expressions = new .();

        if (Parser.Parse(tokens, expressions) case .Err)
        {
            for (let e in expressions)
            {
                if (e != null) delete e;
            }
            delete expressions;
            return .Err(Exit.Software);
        }

        return expressions;
    }

    Result<ByteCodeList, int> GetByteCode(ExpressionList expressions)
    {
        List<uint16> code = new .();

        if (CodeGenerator.Generate(expressions, code) case .Err)
        {
            delete code;
            return .Err(Exit.Software);
        }

        return .Ok(code);
    }

    Result<int> Execute(ByteCodeList code)
    {
        return .Ok(Exit.Ok);
    }

    Result<int, int> StaticAnalysis(List<Expression> list)
    {
        return .Ok(Exit.Ok);
    }
}