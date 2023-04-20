# Todo

- [] Fix the reported memory leak by valgrind in TableAdjustCapacity.

# Done
- [X] Find a way to intern String with the current design of not having a global ijoVM obj. We can't follow the same pattern than in the book.
- [X] Implement a simple GC. ~~For now, if we use String concatenation there will be memory leaks.~~