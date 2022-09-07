using System;
using System.Collections;
using ijo.AST;
namespace ijo;

class VirtualMachine
{
    private Scanner Scanner = new .() ~ delete _;
    private Parser Parser = new .() ~ delete _;
    private AstPrinter AstPrinter = new .() ~ delete _;
    private ByteCodeGenerator CodeGenerator = new .() ~ delete _;

    typealias TokenList = List<Token>;
    typealias ExpressionList = List<Expression>;
    typealias ByteCodeList = List<uint16>;

    public int Run(String source)
    {
        let tokens = CallOrReturn!(Scan(source));
        let expressions = CallOrReturn!(Parse(tokens));

#if DEBUG
        AstPrinter.Print(expressions);
#endif

        CallOrReturn!(StaticAnalysis(expressions));

        let code = CallOrReturn!(GetByteCode());

#if DEBUG
        // Print ByteCode
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