from fastapi import FastAPI
from firebase_admin import credentials, initialize_app
import os
import uvicorn

# Initialize Firebase
# Note: You need to place your serviceAccountKey.json in this directory
try:
    cred = credentials.Certificate("serviceAccountKey.json")
    initialize_app(cred)
except Exception as e:
    print(f"Firebase Init Warning: {e}. Ensure serviceAccountKey.json is present.")

app = FastAPI(title="Nirmth Ghar Connect API")

# Placeholder for modular routers
@app.get("/")
def health_check():
    return {"status": "operational", "project": "Nirmth Ghar Connect"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
