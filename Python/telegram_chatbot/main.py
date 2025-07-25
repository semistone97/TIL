# main.py
# 터미널에서 아래 3줄 실행하고 코드 실행
# pip install fastapi
# pip install 'uvicorn[standard]'
# uvicorn main:app --reload
    # main:app -> main 파일의 app 변수
        # 당연히 이걸 하려면 main이 있는 폴더에서 실행해야겠지~?~?~?
## control + c : 서버종료.

from fastapi import FastAPI, Request
# 서버에 요청을 하는 프로그램: 브라우저
import random
import requests
from dotenv import load_dotenv # pip install dotenv
import os
from openai import OpenAI

# .env 파일에 내용들을 불러옴
load_dotenv()

app = FastAPI()
# 이제 프레임워크를 쓸 거임.
# 이 아래부터는 서버코드임.(내가 서버다)

# main page 문법(home)
@app.get('/')
def home():
    return 'why no just str...'

# /docs 하면 라우팅 목록 페이지로 이동 가능

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
    bot_token = os.getenv('TELEGRAM_BOT_TOKEN')
    URL = f'https://api.telegram.org/bot{bot_token}' #URL의 기본값.
    body = {
        'chat_id':'7765888516',
        'text': '지랄하지마',
    }
    requests.get(URL + '/sendMessage', body)
    return{'status': 'gogogo'}

# 현재 주소로 나오는 '127.0.0.1:8000' == 'localhost'
## 지금 우리 컴퓨터 안에서 서버가 돌고 있음.
### NGROK으로 서버를 돌리게 되면, 내부외부에 걸쳐져있는 NGROK이 외부 요청을 컴퓨터 내 서버에 전달

# 텔레그램 라우팅으로 텔레그램 서버가 Bot에 업데이트가 있을 경우, 우리에게 알려줌
def send_msg(chat_id, text):
    bot_token = os.getenv('TELEGRAM_BOT_TOKEN')
    URL = f'https://api.telegram.org/bot{bot_token}'
    body = {
        # 사용자 chat_id 가져오기
        'chat_id':chat_id,
        'text': text,
    }
    requests.get(URL + '/sendMessage', body)
    
@app.post('/telegram')
async def telegram(request: Request):
    print('텔레그램 요청이 들어왔다!')
    data = await request.json()
    sender_id = data['message']['chat']['id']
    input_msg = data['message']['text']
    # 텔레그램이 가져다 준 Update를 에디터에 print
    print(data)
    client = OpenAI(api_key = os.getenv('OPENAI_API_KEY'))
    res = client.responses.create(
        model='gpt-4.1-mini',
        input=input_msg, 
        instructions='you are a very cute puppy who know a lot about animals and you have a name pppommmi'
    )

    send_msg(sender_id, res.output_text)         # answer to the bot
    return {'status': '굿'}

# get일 때는 안 되고, post로 바꾸니까 됨
# 1. telegram이 setWebhook를 통해 정해진 url에 post request를 보낸다
# 2. 우리 서버의 라우터 설정은 get, 그래서 405 error가 뜸.
# 3. get을 post로 바꿈으로써 라우터가 맞춰지고 response가 나옴.

##############################################################################################################################

# 이제 chatGPT 쓴다.
