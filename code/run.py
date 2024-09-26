from transformers import AutoModelForCausalLM, AutoTokenizer
from PIL import Image
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import base64
from io import BytesIO

from fastapi.staticfiles import StaticFiles
from fastapi import FastAPI, File, UploadFile, Form, Request
from fastapi.responses import HTMLResponse


class ImageQuestion(BaseModel):
    image: str
    question: str
    
    
class EndpointHandler():
    
    def __init__(self) -> None:
        self.model_id = "vikhyatk/moondream2"
        self.revision = "2024-07-23"
        self.model = AutoModelForCausalLM.from_pretrained(
            self.model_id, trust_remote_code=True, revision=self.revision
        )
        self.tokenizer = AutoTokenizer.from_pretrained(self.model_id, revision=self.revision)
    

    def process(self, img, question):
        # image = Image.open(img)
        enc_image = self.model.encode_image(img)
        return self.model.answer_question(enc_image, question, self.tokenizer)    

        
    def preprocess_image(self, encoded_image):
        """Decode and preprocess the input image."""
        decoded_image = base64.b64decode(encoded_image)
        img = Image.open(BytesIO(decoded_image)).convert("RGB")
        return img

app = FastAPI()
app.mount("/app", StaticFiles(directory="static",html = True), name="static")

handler = EndpointHandler()

# @app.get("/")
# async def root():
#     return {"message": "Hello World"}

@app.post("/process",  response_class=HTMLResponse)
async def process_image_and_question(data: Request):
    try:
        
        # Decode the base64 image
        # inputs = data.pop("inputs", data)
        contents = await data.form()
        input_image = contents["image"]
        question = contents["question"]
        im = Image.open(input_image.file)

        
        # img = handler.preprocess_image(input_image)
        answer = handler.process(im, question)

        # Return a response that confirms the image and question were received
        # return {
        #     "message": "Image and question processed successfully",
        #     "answer": answer,
        #     "received_question": question
        # }
        
        
        html_content = f"""
    <html>
        <head>
            <title>Processing Result</title>
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    background-color: #f4f4f4;
                    color: #333;
                    padding: 20px;
                }}
                .container {{
                    max-width: 600px;
                    margin: auto;
                    background: white;
                    padding: 20px;
                    border-radius: 10px;
                    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
                }}
                h1 {{
                    color: #4CAF50;
                }}
                p {{
                    font-size: 16px;
                }}
                .answer {{
                    font-weight: bold;
                    color: #333;
                    background: #e0e0e0;
                    padding: 10px;
                    border-radius: 5px;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Processing Result</h1>
                <p><strong>Message:</strong> Image and question processed successfully.</p>
                <p><strong>Answer:</strong></p>
                <div class="answer">{answer}</div>
                <p><strong>Received Question:</strong> {question}</p>
            </div>
        </body>
    </html>
    """
        return HTMLResponse(content=html_content, status_code=200)

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# To run the app, use the command: uvicorn script_name:app --reload
