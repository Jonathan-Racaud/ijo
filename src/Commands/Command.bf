using System;
using System.Collections;
namespace ijoLang.Commands;

typealias CommandHandler = delegate int(Command);

struct Command : IDisposable
{
    public StringView Name;
    public StringView ParameterString;
    public CommandHandler Handler;

    public void Dispose()
    {
        delete Handler;
    }
}

class CommandManager
{
    private List<Command> commands = new .();
    private Command help;

    public this(Command help)
    {
        this.help = help;
    }

    public ~this()
    {
        for (let command in commands) {
            command.Dispose();
		}
        delete commands;

        help.Dispose();
    }

    public void Register(Command command)
    {
        commands.Add(command);
    }

    public bool HasCommandWithName(StringView name)
    {
        let index = commands.FindIndex(scope (x) => {
            return x.Name == name;
		});

        return index > -1;
    }

    public Command GetCommandWithName(StringView name)
    {
        let index = commands.FindIndex(scope (x) => {
            return x.Name == name;
    	});

        if (index == -1)
            return help;

        return commands[index];
    }
}