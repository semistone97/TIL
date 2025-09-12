# State 정의

from langgraph.graph import MessagesState
from typing_extensions import Any
from typing import Optional


class State(MessagesState):
    pass
    question: str  # 사용자 질문
    is_applicable: Optional[bool] # 질문 답변 라우터.
    reject_reason: Optional[str] # 요청 거절 이유
    dataset: Optional[Any]   # 임의이 데이터셋(추후엔 DB에서 가져오거나 해야함)
    sql: Optional[str]       # SQL 쿼리
    view: Optional[Any]      # 뷰
    code: Optional[str]      # 파이썬 코드 블럭
    py_result: str    # `code`의 실행결과
    answer: str    # 최종 답변
    saved_path: str # 코드 저장 경로