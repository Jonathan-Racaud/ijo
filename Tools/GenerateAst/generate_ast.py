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
            f"    public abstract class {basename} {{}}\n\n"
        ])

        for str in types:
            classname = str.split(':')[0].strip()
            fields = str.split(':')[1].strip()

            define_types(file, basename, classname, fields)
        
        file.write("}")

def define_types(file, basename, classname, fieldList):
    file.writelines([
        f"    public static class {classname}: {basename}\n",
         "    {\n"
    ])

    fields = fieldList.split(', ')
    for field in fields:
        file.write(f"        private static {field};\n")
    
    file.writelines([
        f"        public static void Init({fieldList})\n",
         "        {\n"
    ])

    for field in fields:
        name = field.split(' ')[1]
        file.write(f"            {classname}.{name} = {name};\n")
    
    file.write("        }\n")
    file.write("    }\n\n")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: generate_ast <output directory>")
        sys.exit(64)

    output_dir = sys.argv[1]
    define_ast(output_dir, "Expr", [
        "Binary		: Expr left, Token op, Expr right",
        "Grouping	: Expr expression",
        "Literal	: Variant value",
        "Unary		: Token op, Expr expression"
    ])

