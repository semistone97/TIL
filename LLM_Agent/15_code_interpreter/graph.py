from state import State
from nodes import write_sql, execute_sql, generate_code, execute_code, save_code, generate_answer
from langgraph.checkpoint.memory import InMemorySaver

# 파일에서   # 클래스 가져오기

# graph.py
# builder를 만들고 최종 compile()을 실행하는 곳

from langgraph.graph import StateGraph, START, END

builder = StateGraph(State)
builder.add_sequence([
    write_sql, execute_sql,
    generate_code, execute_code, save_code, generate_answer
])

builder.add_edge(START, 'write_sql')
builder.add_edge('generate_answer', END)

memory = InMemorySaver()


graph = builder.compile()