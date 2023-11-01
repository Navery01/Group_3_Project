
from itertools import permutations

import pyautogui as py

import time
numbers = [1, 2, 3, 4, 5, 6]

all_permutations = list(permutations(numbers))

time.sleep(5)

for perm in all_permutations:
    py.typewrite("run")
    py.press("enter")
    py.typewrite("YOU DIDN'T SAY THE MAGIC WORD!")
    py.press("enter")
    py.typewrite("1 2 4 8 16 32")
    py.press("enter")
    py.typewrite("1 h 705")
    py.press("enter")
    py.typewrite("8 1")
    py.press("enter")
    py.typewrite("mfsdhg")
    py.press("enter")
    py.typewrite(f"{perm[0]} {perm[1]} {perm[2]} {perm[3]} {perm[4]} {perm[5]}")
    py.press("enter")
    py.typewrite("kill")
    py.press("enter")
    py.typewrite("y")
    py.press("enter")





