
import os

def count_braces(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    stack = []
    for i, char in enumerate(content):
        if char == '{':
            stack.append(i)
        elif char == '}':
            if stack:
                start = stack.pop()
                # print(f"Brace pair: {start} - {i}")
            else:
                print(f"Extra closing brace at index {i}")
    
    if stack:
        for s in stack:
            print(f"Unclosed opening brace at index {s}")

count_braces(r'D:\Flutter projects\task_manager_app\lib\screens\login_screen.dart')
