using System;
using System.Collections;
using ijo.AST;
namespace ijo;

class VirtualMachine
{
    public bool IsInRepl;

    private Scanner Scanner = new .() ~ delete _;
    private Parser Parser = new .() ~ delete _;
    private Scope Scope = new .() ~ delete _;

    private ByteCodeGenerator CodeGenerator = new .(this.Scope) ~ delete _;
    private ByteCodeExecutor CodeExecutor = new .(this.Scope) ~ delete _;

#if DEBUG_AST
    private AstPrinter AstPrinter = new .() ~ delete _;
#endif

#if DEBUG_BYTE_CODE
    private ByteCodePrinter BCodePrinter = new .(Scope) ~ delete _;
#endif

    typealias TokenList = List<Token>;
    typealias ExpressionList = List<Expression>;
    typealias ByteCodeList = List<uint16>;

    public int Run(String source)
    {
        List<Token> tokens = null;
        List<Expression> expressions = null;
        List<uint16> code = null;

        defer
        {
            if (tokens != null)
            {
                tokens.Clear();
                delete tokens;
            }

            if (expressions != null)
            {
                ClearAndDeleteItems!(expressions);
                delete expressions;
            }

            if (code != null)
            {
                code.Clear();
                delete code;
            }
        }

        tokens = CallOrReturn!(Scan(source));
        expressions = CallOrReturn!(Parse(tokens));

#if DEBUG_AST
        AstPrinter.Print(expressions);
#endif

        CallOrReturn!(StaticAnalysis(expressions));

        code = CallOrReturn!(GetByteCode(expressions));

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

        if (IsInRepl && code.Count > 0 && ((OpCode)code[code.Count - 1] != .Print))
        {
            code.Add(OpCode.Print);
        }

        code.Add(OpCode.Return);

        return .Ok(code);
    }

    Result<int> Execute(ByteCodeList code)
    {
        CodeExecutor.Execute(code);
        return .Ok(Exit.Ok);
    }

    Result<int, int> StaticAnalysis(List<Expression> list)
    {
        return .Ok(Exit.Ok);
    }
}