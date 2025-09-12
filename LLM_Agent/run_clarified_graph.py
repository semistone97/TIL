import os
from typing import TypedDict

from dotenv import load_dotenv
from langchain_openai import ChatOpenAI
from langchain_community.utilities import SQLDatabase
from langchain_community.tools.sql_database.tool import QuerySQLDataBaseTool
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.pydantic_v1 import BaseModel, Field
from langgraph.graph import StateGraph, END, START

# 1. 수정된 질문 클리어링 노드 함수 임포트
from clarification_node import clarify_question

# 2. 환경 설정
load_dotenv()
llm = ChatOpenAI(model='gpt-4o', temperature=0)

POSTGRES_USER = os.getenv('POSTGRES_USER')
POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD')
POSTGRES_DB = os.getenv('POSTGRES_DB')
URI = f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@localhost:5432/{POSTGRES_DB}"
db = SQLDatabase.from_uri(URI)

# 3. LangGraph 상태 정의 (수정됨)
class State(TypedDict):
    question: str
    sql: str
    result: str
    answer: str
    route: str  # 라우팅 결정을 저장할 필드

# 4. 각 노드에서 사용할 모델 및 프롬프트 정의
class QueryOutput(BaseModel):
    """Generate SQL query"""
    query: str = Field(description="문법적으로 올바른 SQL 쿼리")

system_message = """
Given an input question, create a syntactically correct {dialect} query to
run to help find the answer. Unless the user specifies in his question a
specific number of examples they wish to obtain, always limit your query to
at most {top_k} results. You can order the results by a relevant column to
return the most interesting examples in the database.

Never query for all the columns from a specific table, only ask for a the
few relevant columns given the question.

Pay attention to use only the column names that you can see in the schema
description. Be careful to not query for columns that do not exist. Also,
pay attention to which column is in which table.

Only use the following tables:
{table_info}
"""
query_prompt_template = ChatPromptTemplate.from_messages([
    ("system", system_message),
    ("user", "Question: {input}"),
])

# 5. 워크플로우를 구성할 노드 함수들 정의
def write_sql_node(state: State):
    """사용자 질문을 SQL 쿼리로 변환"""
    print("---'SQL 쿼리 생성'---")
    prompt = query_prompt_template.invoke({
        "dialect": db.dialect,
        "top_k": 10,
        "table_info": db.get_table_info(),
        "input": state["question"],
    })
    structured_llm = llm.with_structured_output(QueryOutput)
    result = structured_llm.invoke(prompt)
    return {"sql": result.query}

def execute_sql_node(state: State):
    """생성된 SQL 쿼리를 DB에서 실행"""
    print("---'SQL 쿼리 실행'---")
    execute_query_tool = QuerySQLDataBaseTool(db=db)
    result = execute_query_tool.invoke(state['sql'])
    return {'result': result}

def generate_answer_node(state: State):
    """DB 조회 결과를 바탕으로 최종 답변 생성"""
    print("---'최종 답변 생성'---")
    prompt = f"""
    주어진 사용자 질문에 대해, DB에서 실행한 SQL 쿼리와 결과를 바탕으로 답변해.
    Question: {state['question']}
    SQL Query: {state['sql']}
    SQL Result: {state['result']}
    """
    res = llm.invoke(prompt)
    return {'answer': res.content}

def clarification_node_wrapper(state: State):
    """clarify_question 함수를 LangGraph 노드 형식에 맞게 감싸는 함수"""
    return clarify_question(state, llm, db)

# 6. 그래프 빌드 및 엣지 연결 (수정됨)
builder = StateGraph(State)

builder.add_node("clarify_question", clarification_node_wrapper)
builder.add_node("write_sql", write_sql_node)
builder.add_node("execute_sql", execute_sql_node)
builder.add_node("generate_answer", generate_answer_node)

builder.add_edge(START, "clarify_question")

# 조건부 엣지 수정: 상태(state)에서 'route' 값을 읽어 분기하도록 변경
builder.add_conditional_edges(
    "clarify_question",
    lambda state: state["route"],  # 상태의 'route' 키 값을 확인
    {
        "related": "write_sql",
        "not_related": END,
    },
)

builder.add_edge("write_sql", "execute_sql")
builder.add_edge("execute_sql", "generate_answer")
builder.add_edge("generate_answer", END)

graph = builder.compile()

# 7. 그래프 실행 및 테스트
if __name__ == "__main__":
    print("---'DB 관련 질문 테스트'---")
    related_question = "직원 목록 좀 보여줘"
    related_output = graph.invoke({"question": related_question})
    print("\n[최종 답변]:", related_output.get('answer'))

    print("\n" + "="*50 + "\n")

    print("---'DB 비관련 질문 테스트'---")
    not_related_question = "오늘 날씨 어때?"
    not_related_output = graph.invoke({"question": not_related_question})
    if not not_related_output.get('answer'):
        print("\n[최종 답변]: DB와 관련 없는 질문으로 판단되어 작업을 중단했습니다.")