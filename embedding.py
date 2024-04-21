from fastapi import FastAPI, UploadFile, File
from sentence_transformers import SentenceTransformer
from PIL import Image
import io

app = FastAPI()
img_model = SentenceTransformer('clip-Vit-B-32')

@app.post("/get_embedding")
async def get_embedding(image: UploadFile = File(...)):
    """
    Receives an image file and returns its embedding.
    """

    try:
        # Read the image content into a bytes stream
        content = await image.read()
        image_bytes = io.BytesIO(content)

        # Open the image from the bytes stream using PIL
        image = Image.open(image_bytes)

        # Encode the image and return the embedding
        embedding = img_model.encode(image)
        return {"embedding": embedding.tolist()}

    except (FileNotFoundError, ValueError) as e:
        # Handle potential errors like invalid image format
        return {"error": f"Invalid image file: {str(e)}"}, 400

    except Exception as e:
        # Catch other unexpected errors
        return {"error": "Internal server error"}, 500
