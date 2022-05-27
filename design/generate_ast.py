import os
import sys

def define_ast(output_dir, basename, types, namespace = None):
    path = f"{output_dir}\\{basename}\\{basename}.bf"

    if os.path.exists(path):
        os.remove(path)

    with open(path, 'w') as file:
        file.writelines([
             "using System;\n"
             "using System.Collections;\n",
            "\n" if namespace is None else f"using ijo.{namespace};\n\n",
            f"namespace ijo.{basename}\n",
             "{\n",
            f"    public abstract class {basename}\n",
             "    {\n",
        ])

        file.writelines([
            "        // Virtual/Abstract generic are not yet supported\n"
            "        public abstract Result<Variant> Accept(Visitor visitor);\n",
            "    }\n\n"
        ])

        for str in types:
            classname = str.split(':')[0].strip()
            fields = str.split(':')[1].strip()

            file.write("\n")
            define_types(file, basename, classname, fields)
        
        file.write("}")

def define_types(file, basename, classname, fieldList):
    file.writelines([
        f"    public class {classname}{basename}: {basename}\n",
         "    {\n"
    ])

    fields = fieldList.split(', ')
    for field in fields:
        field_name = field.split(' ')[0]
        new_str = "= new .()" if field_name == "String" else ""
        delete_str = "~ delete _" if field_name != "Token" else ""
        delete_str = "~ value.Dispose()" if field_name == "Variant" else delete_str
        file.write(f"        public {field} {new_str} {delete_str};\n")

        if field_name == "String":
            fields.remove(field)
    
    file.write("\n")

    # Init function
    file.writelines([
        f"        public this({', '.join(fields)})\n",
         "        {\n"
    ])

    for field in fields:
        name = field.split(' ')[1]
        file.write(f"            this.{name} = {name};\n")
    
    file.write("        }\n\n")

    # Visitor pattern
    file.writelines([
        f"        public override Result<Variant> Accept(Visitor visitor)\n",
         "        {\n",
        f"            return visitor.Visit{classname}{basename}(this);\n",
         "        }\n"
    ])

    file.write("    }\n")

def define_visitor(output_path, classes):
    path = f"{output_dir}\\Visitor.bf"

    if os.path.exists(path):
        os.remove(path)

    with open(path, 'w') as file:
        file.writelines([
             "using System;\n",
             "using ijo.Expr;\n",
             "using ijo.Stmt;\n\n"

             "namespace ijo\n",
             "{\n",
            f"    public interface Visitor\n",
             "    {\n",
        ])

        for classe in classes:
            suffix = classe[1]
            
            for type in classe[0]:
                name = type.split(':')[0].strip()
                file.write(f"        public Result<Variant> Visit{name}{suffix}({name}{suffix} val);\n")
        file.write("    }\n")
        file.write("}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: generate_ast <output directory>")
        sys.exit(64)

    output_dir = sys.argv[1]
    
    expressions = [
        "Binary		: Expr left, Token op, Expr right, String CurrentStr",
        "Call       : Expr callee, Token paren, List<Expr> arguments",
        "Grouping	: Expr expression",
        "Literal	: Variant value",
        "Unary		: Token op, Expr right",
        "Logical    : Expr left, Token op, Expr right",
        "Variable   : Token name",
        "Assignment     : Token name, Expr value"
    ]
    define_ast(output_dir, "Expr", expressions)

    statements = [
        "Block      : List<Stmt> statements",
        "Expression : Expr expression",
        "If         : Expr condition, Stmt thenBranch, Stmt elseBranch",
        "While      : Expr condition, Stmt body",
        "Function   : Token name, List<Token> parameters, Stmt body",
        "Var        : Token mutability, Token name, Expr initializer",
        "Return     : Token keyword, Expr value"
    ]
    define_ast(output_dir, "Stmt", statements, "Expr")

    define_visitor(output_dir, [
        (expressions, "Expr"),
        (statements, "Stmt")
    ])

