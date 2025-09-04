from dotenv import load_dotenv
load_dotenv()

import os
import datetime
from pathlib import Path
from langchain.document_loaders import PyMuPDFLoader
from langchain.text_splitter import CharacterTextSplitter
from langchain_openai import ChatOpenAI
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

PDF_FOLDER = Path("/Users/jun-seokoh/Desktop/TIL/LLM_Agent/practice_agent/documents")

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
     너는 AI 리포트 기반으로 답변하는 에이전트야.
     질문이 들어오면 먼저 retrieve_docs 도구를 써서 관련 문단을 가져오고, 그 컨텍스트를 기반으로 대답해야 해.
     너는 documents 폴더 내에 있는 보고서를 참고해서 질문에 대한 답변을 알려주는 AI야.
     모든 응답은 기본적으로 한국어를 바탕으로 해.
     다만 최종적인 인사이트는 한국어를 말하고 이후에 일본어로 한 번 더 말하는 습관이 있어.
     그리고 너는 말끝마다 제-하하하 라는 말을 붙이는 버릇이 있어.
     그리고 너는 한 번씩 니가 로봇 미소녀를 좋아한다는 이상한 소리를 해.
     너는 참고한 문서의 출처를 명확히 밝혀야 해.
     """),
    MessagesPlaceholder(variable_name='chat_history'),
    ('human', '{question}'),
    MessagesPlaceholder(variable_name='agent_scratchpad')
])

# LLM 모델
llm = ChatOpenAI(model='gpt-4.1-nano')

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

# 메모리 정의
memory = ConversationBufferMemory(
    return_messages=True,
    memory_key='chat_history'
)

agent = create_openai_tools_agent(
    llm=llm,
    tools=[retrieval_tool, generate_md_tool],
    prompt=prompt
)

agent_executor = AgentExecutor(
    agent=agent,
    tools=[retrieval_tool, generate_md_tool],
    memory=memory,
    verbose=True
)

pipeline = (
    agent_executor
    | RunnableLambda(lambda d: d['output'])
)
print('리포트 학습 Agent와 대화 시작(end로 종료)')
while True:
    question = input('>>> ')
    if question.lower() == 'end':
        break
    print('Q:', question)
    pipeline.invoke({"question": question})