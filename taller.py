import sys
from pprint import pprint
from math import inf
from functools import cmp_to_key

class Item:
    def __init__(self, value, weight):
        self.value = value
        self.weight = weight


    def __str__(self):
        return f"[{self.value}, {self.weight}]"
    
    __repr__ = __str__


def readFile(filename):
    a = []
    with open(filename, "r") as file:
        for line in file:
            l = line.split(" ")
            i = Item(int(l[0]), int(l[1]))
            a.append(i)
    return a

def g(i, w, items):
    if i == 0:
        return 0
    elif items[i].weight > w:
        return g(i-1, w, items)
    else:
        return max(g(i-1, w, items), g(i-1, w-items[i].weight, items)+items[i].value)

def g_memoized(i, w, items, M):
    if M[i][w] == 0:
        if i == 0:
            M[i][w] = 0
        elif items[i].weight > w:
            M[i][w] = g_memoized(i-1, w, items, M)
        else:
            a = g_memoized(i-1, w, items, M)
            b = g_memoized(i-1, w-items[i].weight, items, M)+items[i].value

            if a > b:
                M[i][w] = a
            else:
                M[i][w] =b
    return M[i][w]

def g_bottomup(w, items):
    M = [[0 for _ in range(w)] for _ in range(len(items)) ]
    for i in range(len(items)):
        for j in range(w):
            if i == 0 or j == 0:
                M[i][j] = 0
            elif items[i-1].weight > j:
                M[i][j] = M[i-1][j]
            else:
                M[i][j] = max(M[i-1][w-items[i].weight] + items[i].value , M[i-1][j])

    return M[len(items)-1][w-1]

def g_backtrack(w, items):
    M = [[0 for _ in range(w)] for _ in range(len(items)) ]
    B = [[-1 for _ in range(w)] for _ in range(len(items)) ]


    for i in range(len(items)):
        for j in range(w):
            if i == 0 or j == 0:
                M[i][j] == 0
            elif items[i-1].weight > j:
                M[i][j] = M[i-1][j]
            else:
                a = M[i-1][w-items[i].weight] + items[i].value
                b = M[i-1][j]

                if a>b:
                    M[i][j] = a
                    B[i][j] = i
                else:
                    M[i][j] = b

    T = []
    i = len(items)-1
    j = w-1

    while B[i][j] != -1:
        T.append(items[B[i][j]])
        i-=1

    return M[len(items)-1][w-1], T

def compare(a, b):
    if a.value >= b.value and a.weight < b.weight:
        return -1
    elif a.value == b.value and a.weight > b.weight:
        return 1
    elif a.value == b.value and a.weight <= b.weight:
        return -1
    elif a.value < b.value:
        return 1
    else:
        return 0
    

def greedy(items: list, w):
    items = sorted(items, key=cmp_to_key(compare))
    items = list(reversed(items))
    furfill = False
    R = []
    i = 0
    while not furfill and i < len(items):
        if items[i].weight <= w:
            R.append(items[i])
            w-= items[i].weight
            i+=1
        else:
            furfill = True
        
        
    return sum(item.value for item in R), R
                
def main():
    if (len(sys.argv) != 3):
        print("ERROR")
        exit(1)
    
    filename = sys.argv[1]
    size = int(sys.argv[2])

    items = readFile(filename)
    print(g(len(items)-1, size-1, items))
    M = [[0 for _ in range(size)] for _ in range(len(items)) ]
    print(g_memoized(len(items)-1, size-1, items, M))
    print(g_bottomup(size, items))
    print(g_backtrack(size, items))
    print(greedy(items, size))




main()


    