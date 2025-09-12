import os
import uuid
from state import State
from langchain_openai import ChatOpenAI
from typing_extensions import TypedDict, Annotated
from langchain_experimental.utilities import PythonREPL
from postgresql import db, query_prompt_template
from langchain_community.tools.sql_database.tool import QuerySQLDataBaseTool


llm = ChatOpenAI(model='gpt-4o', temperature=0)

class QueryOutput(TypedDict):
    """Generate SQL query"""
    query: Annotated[str, ..., '문법적으로 올바른 SQL 쿼리']

class CodeBlock(TypedDict):
    code: Annotated[str, ..., '바로 실행 가능한 파이썬 코드']


# SQL 생성 Node
def write_sql(state: State):
    """Generate SQL query to fetch info"""
    prompt = query_prompt_template.invoke({
        "dialect": db.dialect,
        "top_k": 10,
        "table_info": db.get_table_info(),
        "input": state["question"],
    })
    structured_llm = llm.with_structured_output(QueryOutput)
    result = structured_llm.invoke(prompt)
    return {'sql': result["query"]}

def execute_sql(state: State):
    """Execute SQL Query"""
    execute_query_tool = QuerySQLDataBaseTool(db=db)
    result = execute_query_tool.invoke(state['sql'])
    return {'result': result}

def generate_code(state: State):
    prompt = f'''
    사용자 질문과 데이터셋을 제공할거야. 사용자 질문에 답변하기 위한 파이썬 코드를 생성해 줘.
    코드는 간단할수록 좋고, numpy, pandas, scikit-learn, scipy 가 설치되어 있으니 편하게 사용해.
    [주의] 이 코드는 실행될거기 때문에, 위험한 코드는 작성하면 안돼!
    ---
    질문: {state['question']}
    ---
    데이터셋: {state['dataset']}
    ---
    코드: {state['code']}
    '''
    s_llm = llm.with_structured_output(CodeBlock)
    res = s_llm.invoke(prompt)
    return {'code': res['code']}

def execute_code(state: State):
    repl = PythonREPL()
    result = repl.run(state['code'])
    return {'result': result.strip()}

def generate_answer(state: State):
    prompt = f'''
    우리는 사용자 질문 -> 코드 -> 결과를 가지고 있어
    사용자의 질문과, 실행코드와 결과를 종합해 최종 답변을 생성해라.
    실행코드를 기반으로 왜 이 결과가 나왔는지 설명하면 된다.
    ---
    질문: {state['question']}
    ---
    코드: {state['code']}
    ---
    결과: {state['py_result']}
    ---
    최종 답변:
    '''
    res = llm.invoke(prompt)
    return {'answer': res}


def save_code(state: State):
    """
    코드를 특정 폴더에 저장합니다.
    """
    # 'codes' 폴더가 없으면 생성
    if not os.path.exists("codes"):
        os.makedirs("codes")

    # 고유한 파일 이름 생성
    filename = f"codes/code_{uuid.uuid4()}.py"
    
    # state에서 질문과 코드 가져오기
    question = state.get('question', 'No question provided.')
    code_to_save = state.get('code', '')

    # 질문을 docstring으로 추가
    docstring = f'"""\n[USER QUESTION]\n{question}\n"""\n\n'
    content_to_save = docstring + code_to_save
    
    # 파일에 코드 저장
    with open(filename, "w", encoding="utf-8") as f:
        f.write(content_to_save)
        
    # 파일 경로 반환
    return {'saved_path': filename}