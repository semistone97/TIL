from langchain_core.prompts import ChatPromptTemplate
from langchain_core.pydantic_v1 import BaseModel, Field

def clarify_question(state: dict, llm, db) -> dict:
    """
    Determines if the user's question is related to the database schema and
    returns a dictionary to update the graph's state with the routing decision.
    """
    print("---DB 관련성 체크---")

    class RouteQuery(BaseModel):
        """Routes a user query to a data source."""
        datasource: str = Field(
            description="Given a user question, determine if it is related to the database. Route to 'related' if it is, otherwise route to 'not_related'.",
            enum=["related", "not_related"],
        )

    prompt = ChatPromptTemplate.from_messages(
        [
            (
                "system",
                "You are an expert at routing a user question to a SQL database or not. "
                "Use the database schema below to determine if the question is related. "
                "Do not attempt to answer the question, just route it based on the schema."
                "The user's question is in Korean."
                "\n\n<SCHEMA>\n{schema}\n</SCHEMA>",
            ),
            ("human", "{question}"),
        ]
    )
    structured_llm = llm.with_structured_output(RouteQuery)
    router = prompt | structured_llm
    result = router.invoke({
        "question": state['question'],
        "schema": db.get_table_info(),
    })

    print(f"---라우팅 결정: {result.datasource}---")
    if result.datasource == "related":
        print("---결정: 질문이 DB와 관련됨---")
        return {"route": "related"}
    else:
        print("---결정: 질문이 DB와 관련 없음---")
        return {"route": "not_related"}