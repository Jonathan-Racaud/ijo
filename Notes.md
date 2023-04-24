# Why a single-pass compiler
The first implementation follows the book [Crafting Interpreters](https://craftinginterpreters.com). It implements clox using a single-pass compiler because it is simple.

It however states the following: 
> Single-pass compilers like we’re going to build don’t work well for all languages. Since the compiler has only a peephole view into the user’s program while generating code, the language must be designed such that you don’t need much surrounding context to understand a piece of syntax

I do not have enough experience to see if this approach will work or not for ijo. If not, then the implementation will be rewritten.