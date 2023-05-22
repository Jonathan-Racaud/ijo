# Todo
- [] Fix Loops.
```ijo
~($i = 0; i < 5; i = i + 1) {
	%>> i
}

%>> "-----"

{
	$i = 5
	~(i < 10; i = i + 1) {
		%>> i
	}
}

%>> "-----"

{
	$i = 10
	~(i < 15) {
		%>> i
		i = i + 1
	}
}

#MAX = 18

{
	$num = 16
	~(num <= MAX) {
		%>> num
		num = num + 1
	}

	%>> "Bye!"
}
```
This should print
```ijo
0
1
2
3
4
-----
5
6
7
8
9
-----
10
11
12
13
14
-----
16
17
18
Bye!
```
But depending on my experiments at the moment, I either have it print a 15 (which should be impossible) or it enters an infinite loop.

- [] Better handle submodules.

# Done
- [X] Make the examples/var.ijo code work as expected.
- [X] Fix the reported memory leak by valgrind in TableAdjustCapacity.
- [X] Find a way to intern String with the current design of not having a global ijoVM obj. We can't follow the same pattern than in the book.
- [X] Implement a simple GC. ~~For now, if we use String concatenation there will be memory leaks.~~