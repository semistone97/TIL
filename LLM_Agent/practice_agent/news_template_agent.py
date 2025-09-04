from dotenv import load_dotenv
load_dotenv()

import os
import datetime
from pathlib import Path
from langchain.document_loaders import PyMuPDFLoader
from langchain.text_splitter import CharacterTextSplitter
from langchain_core.prompts import PromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnableLambda
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain.text_splitter import CharacterTextSplitter
from langchain.memory import ConversationBufferMemory
from langchain.agents import create_openai_tools_agent, AgentExecutor
from pydantic import BaseModel, Field
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import FAISS
from langchain.tools import StructuredTool
from langchain.tools import Tool
import pandas as pd
from langchain_google_genai import ChatGoogleGenerativeAI


PDF_FOLDER = Path('/Users/jun-seokoh/Desktop/TIL/LLM_Agent/practice_agent/news')

def load_all_pdfs_from_folder(folder_path: Path = PDF_FOLDER):
    # 1) documents 폴더 경로 설정
    pdf_folder = Path(folder_path)
    if not pdf_folder.exists():
        raise FileNotFoundError(f"폴더가 존재하지 않습니다: {pdf_folder.resolve()}")
    
    # 2) 폴더 내 모든 .pdf 파일 찾기
    pdf_paths = sorted(pdf_folder.glob("*.pdf"))
    if not pdf_paths:
        raise FileNotFoundError(f"No PDF files found in {pdf_folder.resolve()}")
    
    # 3) 각 PDF 로드하여 Document 리스트에 누적
    all_docs = []
    for pdf_path in pdf_paths:
        loader = PyMuPDFLoader(str(pdf_path))
        docs = loader.load()
        print(f"📄 Loaded {len(docs)} pages from {pdf_path.name}")
        all_docs.extend(docs)
    
    print(f"✅ 총 로드된 페이지 수: {len(all_docs)}")
    return all_docs

if __name__ == "__main__":
    # 함수 호출: documents/ 폴더에 있는 모든 PDF를 읽어들임
    documents = load_all_pdfs_from_folder()

# Chunk 분할
splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
chunks = splitter.split_documents(documents)


embedding = OpenAIEmbeddings()
vectorstore = FAISS.from_documents(documents=chunks, embedding=embedding)

prompt = ChatPromptTemplate([
    ('system',
     """
     너는 news 폴더에 있는 기사를 읽고 그걸 csv로 정리해주는 에이전트야.
     질문이 들어오면 먼저 retrieve_docs 도구를 써서 관련 문단을 가져오고, 그 컨텍스트를 기반으로 작업해야 해.
     뉴스를 읽은 뒤에 정해진 컬럼에 맞는 정보로 정리된 csv를 전달해야 해.
     확인할 수 없는 정보는 '확인불가'라고 기입해도 돼.
     각 컬럼별 채워야 하는 사항을 말해줄게.
    •	Case Title: 기사의 제목을 추출. 만약 제목이 영어면 뒤에 한글 제목도 붙여서 채우기.
	•	Country: 사건이 발생된 국가를 채워넣기
	•	Incident Category: 사건의 유형 6개 중 적절한 하나를 골라서 넣기(개인정보유출, 딥페이크, 사이버불링, 부정행위, 부적절한 정보, 저작권 침해)
	•	Incident Description: 사건 요약
	•	Occurrence Date: 사건 발생일. 'YY년 MM월' 이렇게 채우기.
	•	AI Type: 사건에 활용된 AI
	•	Damage Severity: 사건의 피해 심각도.
	•	Response Measures: 대응 방법
	•	Response Effectiveness: 대응이 어느정도 유효했는지를 보고 '유효', '유효하지 않음' 중에 골라서 넣어.
     """),
    MessagesPlaceholder(variable_name='chat_history'),
    ('human', '{question}'),
    MessagesPlaceholder(variable_name='agent_scratchpad')
])

# LLM 모델
llm = ChatGoogleGenerativeAI(
    model="gemini-2.5-pro",  
    # temperature=0.2,
)

# 검색기 생성(retriever 생성)
retriever = vectorstore.as_retriever()

def retrieve_docs(query: str):
    docs = retriever.get_relevant_documents(query)
    # LLM에게 쓸 수 있도록 page_content 만 합쳐서 반환해도 좋고
    return "\n\n".join([d.page_content for d in docs])

# 문서를 리스트로 받아오는 함수
retrieval_tool = Tool.from_function(
    func=retrieve_docs,
    name="retrieve_docs",
    description="AI 리포트에서 질문에 맞는 컨텍스트 문단을 가져오는 도구"
)

# 1) 인수 스키마 정의
class GenerateMDArgs(BaseModel):
    language: str = Field(description="문서의 언어 코드 (예: 'ko')")
    content: str = Field(description="마크다운으로 정리할 콘텐츠")

# 2) 실제 파일 생성 함수 시그니처 변경
def generate_markdown_file(language: str, content: str) -> str:
    now = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"report_{now}.md"
    filepath = os.path.join("/Users/jun-seokoh/Desktop/TIL/LLM_Agent/practice_agent/reports", filename)
    md_content = f"```{language}\n{content}\n```"
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(md_content)
    return filepath

# 3) StructuredTool로 래핑
generate_md_tool = StructuredTool.from_function(
    func=generate_markdown_file,
    name="generate_markdown_file",
    description="주어진 언어와 콘텐츠로 마크다운 파일을 생성하고 경로를 반환",
    args_schema=GenerateMDArgs,
)

# Generate CSV Tooooool
# 1) 인수 스키마 정의
class GenerateCSVArgs(BaseModel):
    title: str = Field(description="사건명")
    country: str = Field(description="사건 발생 국가")
    category: str = Field(description="사건 카테고리")
    description: str = Field(description="사건 상세")
    occurrence_date: str = Field(description="사건 발생일")
    AI_type: str = Field(description="사용된 AI")
    severity: str = Field(description="피해 심각도")
    response: str = Field(description="대응 방법")
    response_effectiveness: str = Field(description="대응 유효성")


# 2) 실제 파일 생성 함수 시그니처 변경
def generate_cases_csv(args: GenerateCSVArgs) -> str:
    # CSV용 데이터 맵핑
    data = {
        "Case Title": [args.title],
        "Country": [args.country],
        "Incident Category": [args.category],
        "Incident Description": [args.description],
        "Occurrence Date": [args.occurrence_date],
        "AI Type": [args.AI_type],
        "Damage Severity": [args.severity],
        "Response Measures": [args.response],
        "Response Effectiveness": [args.response_effectiveness],
    }
    df = pd.DataFrame(data)
    
    # 파일명 및 경로 생성
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"cases_{timestamp}.csv"
    filepath = os.path.join("/Users/jun-seokoh/Desktop/TIL/LLM_Agent/practice_agent/cases", filename)
    
    # CSV로 저장
    df.to_csv(filepath, index=False, encoding="utf-8-sig")
    return filepath


generate_csv_tool = StructuredTool.from_function(
    func=generate_cases_csv,
    args_schema=GenerateCSVArgs,
    name="generate_cases_csv",
    description="사건 정보를 받아 CSV 파일을 생성하고 경로를 반환"
)

# 메모리 정의
memory = ConversationBufferMemory(
    return_messages=True,
    memory_key='chat_history'
)

agent = create_openai_tools_agent(
    llm=llm,
    tools=[retrieval_tool, generate_csv_tool],
    prompt=prompt
)

agent_executor = AgentExecutor(
    agent=agent,
    tools=[retrieval_tool, generate_csv_tool],
    memory=memory,
    verbose=True
)

pipeline = (
    agent_executor
    | RunnableLambda(lambda d: d['output'])
)

question = 'news 폴더에 있는 사건을 정리해서 cases 폴더 내에 csv 파일로 저장해줘.'

pipeline.invoke({"question": question})