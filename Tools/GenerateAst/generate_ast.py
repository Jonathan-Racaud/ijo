import os
import sys

def define_ast(output_dir, basename, types):
    path = f"{output_dir}/{basename}.bf"

    os.remove(path)

    with open(path, 'w') as file:
        file.writelines([
             "using System;\n\n"
             "namespace BLox\n",
             "{\n",
            f"    public abstract class {basename}\n",
             "    {\n",
             "        // Virtual/Abstract generic are not yet supported\n"
             "        public abstract void Accept(Visitor visitor);\n",
             "    }\n\n"
        ])

        define_visitor(file, basename, types)

        for str in types:
            classname = str.split(':')[0].strip()
            fields = str.split(':')[1].strip()

            file.write("\n")
            define_types(file, basename, classname, fields)
        
        file.write("}")

def define_visitor(file, basename, types):
    file.writelines([
        "    public interface Visitor\n",
        "    {\n"
    ])

    for type in types:
        name = type.split(':')[0].strip()
        file.write(f"        void Visit{name}{basename}({name} {basename.lower()});\n")

    file.write("    }\n\n")
    file.writelines([
        "    public interface Visitor<T>: Visitor\n",
        "    {\n"
        "        public T Result { get; };\n"
        "    }\n"
    ])

def define_types(file, basename, classname, fieldList):
    file.writelines([
        f"    public class {classname}: {basename}\n",
         "    {\n"
    ])

    fields = fieldList.split(', ')
    for field in fields:
        file.write(f"        public {field} ~ delete _;\n")
    
    file.write("\n")

    # Init function
    file.writelines([
        f"        public this({fieldList})\n",
         "        {\n"
    ])

    for field in fields:
        name = field.split(' ')[1]
        file.write(f"            this.{name} = {name};\n")
    
    file.write("        }\n\n")

    # Visitor pattern
    file.writelines([
         "        // Virtual/Abstract generic are not yet supported, so we have to rely on 'new' keyword here.\n"
        f"        public override void Accept(Visitor visitor)\n",
         "        {\n",
        f"            visitor.Visit{classname}{basename}(this);\n",
         "        }\n"
    ])

    file.write("    }\n")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: generate_ast <output directory>")
        sys.exit(64)

    output_dir = sys.argv[1]
    define_ast(output_dir, "Expr", [
        #"Equality   : ",
        #"Comparison : ",
        #"Term       : ",
        #"Factor     : ",
        "Unary		: Token op, Expr right",
        #"Primary    : ",
        "Binary		: Expr left, Token op, Expr right",
        "Grouping	: Expr expression",
        "Literal	: Variant value",
    ])

