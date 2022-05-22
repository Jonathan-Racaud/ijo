using System;

namespace ijo.Scanner
{
	enum ScanError
	{
		case UnexpectedCharacter;
		case NonTerminatedString;
		case NumberParsingError;
		case Unknown;

		public static operator StringView(Self value)
		{
			switch (value)
			{
			case .UnexpectedCharacter: return "Unexpected character";
			case .NonTerminatedString: return "Non terminated string";
			case .NumberParsingError: return "Error parsing number";
			case .Unknown: return "Unknown error";
			}
		}
	}
}