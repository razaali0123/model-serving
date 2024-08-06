from transformers import AutoModelForCausalLM, AutoTokenizer
from PIL import Image
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import base64
from io import BytesIO


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
handler = EndpointHandler()

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.post("/process")
async def process_image_and_question(data: ImageQuestion):
    try:
        
        # Decode the base64 image
        # inputs = data.pop("inputs", data)
        input_image = data.image
        question = data.question
        
        img = handler.preprocess_image(input_image)
        answer = handler.process(img, question)

        # Return a response that confirms the image and question were received
        return {
            "message": "Image and question processed successfully",
            "answer": answer,
            "received_question": question
        }

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# To run the app, use the command: uvicorn script_name:app --reload
