from fastapi import FastAPI
from fastapi.responses import HTMLResponse
import os

app = FastAPI()

@app.get("/")
async def read_root():
    return {"message": "Hello, World!"}


@app.get("/hello", response_class=HTMLResponse)
async def hello():
    return """
    <html>
        <head><title>Hello World</title></head>
        <body>
            <h1>Hello, World!</h1>
            <p>This is a FastAPI HTML response.</p>
        </body>
    </html>
    """

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port= int(os.environ.get("PORT", 8080)), debug=True)