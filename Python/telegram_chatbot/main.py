# main.py
# 터미널에서 아래 3줄 실행하고 코드 실행
# pip install fastapi
# pip install 'uvicorn[standard]'
# uvicorn main:app --reload
    # main:app -> main 파일의 app 변수
        # 당연히 이걸 하려면 main이 있는 폴더에서 실행해야겠지~?~?~?
## control + c : 서버종료.

from fastapi import FastAPI
# 서버에 요청을 하는 프로그램: 브라우저
import random
import requests

app = FastAPI()
# 이제 프레임워크를 쓸 거임.
## 이 아래부터는 서버코드임.(내가 서버다)


@app.get('/hi')                 # 얘가 요청(우리가 만든 서버의 요청문을 정하는 것)
def hi():
    return {'왜 안 되누':'아가리해'}    # 얘가 응답.

@app.get('/lotto')
def lotto():
    return {
        'numbers': random.sample(range(1,46),6)
    }

@app.get('/gogogo')
def gogogo():
    bot_token = '8490364531:AAFWMl1N3HAojQAhq5I5dbzH_KiAs0TrEXQ'
    URL = f'https://api.telegram.org/bot{bot_token}' #URL의 기본값.
    body = {
        'chat_id':'7765888516',
        'text': '지랄하지마',
    }
    requests.get(URL + '/sendMessage', body)
    return{'status': 'gogogo'}