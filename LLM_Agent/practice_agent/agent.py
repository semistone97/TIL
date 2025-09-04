from dotenv import load_dotenv
load_dotenv()
from pathlib import Path
from langchain.document_loaders import PyMuPDFLoader
from langchain.text_splitter import CharacterTextSplitter
from langchain_openai import ChatOpenAI
from langchain_core.prompts import PromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_core.output_parsers import StrOutputParser
from langchain.memory import ConversationBufferMemory
from langchain import hub
from langchain.agents import create_openai_tools_agent, AgentExecutor
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

# DOCS_DIR = Path("documents")
# pdf_paths = sorted(DOCS_DIR.glob("*.pdf"))  # documents 폴더 내 모든 .pdf


# # 1. 파일 Load
# docs = []
# for pdf_path in pdf_paths:
#     loader = PyMuPDFLoader(str(pdf_path))
#     docs.extend(loader.load())

# PwC, Deloitte, KPMG 보고서를 각자 PDF로 저장했다고 가정
paths = [
    "practice_agent/documents/deloitte.pdf",
    "practice_agent/documents/kpmg.pdf",
    "practice_agent/documents/pwc.pdf",
]
# 2) 파일별로 Document 리스트를 저장할 딕셔너리 생성
docs_by_file = {}

for path in paths:
    loader = PyMuPDFLoader(path)
    # load() 호출 시 PDF의 각 페이지를 Document 객체로 반환
    docs = loader.load()
    docs_by_file[path] = docs

# 1-3. Chunk 단계: 문서를 작은 청크로 분할
from langchain.text_splitter import CharacterTextSplitter

# 청크 크기와 중첩 설정
splitter = CharacterTextSplitter(
    chunk_size=1000,      # 한 청크당 최대 1000자
    chunk_overlap=200     # 이전 청크와 200자 중첩
)

# 파일별로 분할된 청크 저장
chunks_by_file = {}
all_chunks = []

for path, docs in docs_by_file.items():
    # docs는 1-2에서 전처리된 Document 객체 리스트
    file_chunks = splitter.split_documents(docs)
    chunks_by_file[path] = file_chunks
    all_chunks.extend(file_chunks)

# 확인
for path, file_chunks in chunks_by_file.items():
    print(f"{path} → {len(file_chunks)} chunks created")

print("전체 청크 수:", len(all_chunks))

# 3. Embedding & VectorStore

from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import FAISS

embedding = OpenAIEmbeddings()

vectorstore = FAISS.from_documents(documents=all_chunks, embedding=embedding)

# 4. 최종 답변

# 프롬프트 세팅
# prompt = hub.pull('rlm/rag-prompt')
prompt = ChatPromptTemplate([
    ('system', '너는 첨부된 pwc, deloitte, kpmg 보고서를 참고해서 질문에 대한 답변을 알려주는 AI야. 모든 응답은 한국어로 돼야 해. '),
    # '그리고 너는 말끝마다 우겔겔겔 이라는 말을 붙이는 버릇이 있고, 얼룩말을 아주 좋아해. 그리고 말을 할 때 문서의 어느 부분을 참고했는지 명확하게 밝혀.'),
    MessagesPlaceholder(variable_name='chat_history'),
    ('human', '{question}'),
    MessagesPlaceholder(variable_name='agent_scratchpad')
])

# LLM 모델
llm = ChatOpenAI(model='gpt-4.1-nano')

# 검색기 생성(retriever 생성)
retriever = vectorstore.as_retriever()

# 메모리 정의
memory = ConversationBufferMemory(
    return_messages=True,
    memory_key='chat_history'
)

agent = create_openai_tools_agent(
    llm=llm,
    tools=[],
    prompt=prompt
)

agent_executor = AgentExecutor(
    agent=agent,
    tools=[],
    memory=memory,
    verbose=True
)

from langchain_core.runnables import RunnableLambda

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

