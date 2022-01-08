## Range

```
>>> range(10)
range(0, 10)
>>> list(range(10))
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
>>> list(range(5, 10))
[5, 6, 7, 8, 9]
>>> list(range(5, 10, 3))
[5, 8]
```

## if elif else

```
>>> if i == 45:
...     print('i is 45')
... elif i == 35:
...     print('i is 35')
... elif i%3 == 0:
...     print('multiple of 3')  
... else:
...     print('i dont know')
... 
multiple of 3
>>> cat = 'spot'
>>> if 's' in cat:
...     print("Found an S in cat")
...     if cat == "Sheeba":
...         print ("sheeba")
...     else:
...         print ("some other cat")
... else:
...      print("a cat without an s")
... 
Found an S in cat
some other cat
>>>
```

For loops and breaking a for loop with continue

```
>>> for i in range(10):
...      x=i*2
...      print (x)
... 
0
2
4
6
8
10
12
14
16
18
```
Continue
```
>>> for i in range(6):
...      if i == 3:
...           continue 
...      print (i)
... 
0
1
2
4
5
```

## While loops
This repeat a block as long as a condition evaluates to true
```
>>> while count < 3:
...     print(f"count is {count}")
...     count +=1
... 
count is 0
count is 1
count is 2
```

It is essential to define a way to stop your loop. Otherwise it would be stuck. You could use a break statement to prevent this like so
```
>>> count = 0
>>> while True:
...       print(f"The count is {count}")
...       if count > 5:
...           break 
...       count += 1
... 
The count is 0
The count is 1
The count is 2
The count is 3
The count is 4
The count is 5
The count is 6
```
