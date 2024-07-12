# Package

version       = "0.1.0"
author        = "JRacaud"
description   = "A programming language that has no keywords"
license       = "Proprietary"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["ijo"]
binDir        = "bin"


# Dependencies

requires "nim >= 2.0.6"
requires "fusion"