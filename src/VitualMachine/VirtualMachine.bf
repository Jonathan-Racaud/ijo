using System;
using System.Collections;
using ijoLang.AST;
namespace ijoLang;

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

#if DEBUG_BYTECODE
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
                for (let t in tokens)
                {
                    t.Dispose();
                }

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

#if DEBUG_BYTECODE
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

        let astRes = Parser.Parse(tokens);
        if (astRes case .Err)
        {
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

        let op = (OpCode)code[code.Count - 1];
        if (IsInRepl && code.Count > 0 && (op != .Print))
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