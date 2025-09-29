from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import os

# Modeli güvenli yoldan yükle (mutlak yol)
MODEL_PATH = os.path.abspath("decision_tree_model_v3.pkl")
model = joblib.load(MODEL_PATH)

recommendations = {
    "Düşük": "Harika! Dijital alışkanlıklarınız sağlıklı görünüyor. Böyle devam edin.",
    "Orta": "Telefon kullanımınıza küçük sınırlar koymayı deneyin. Bildirimleri kapatmak iyi bir başlangıç olabilir.",
    "Yüksek": "Ekran sürenizi azaltmak için günlük hedefler koyun ve çevrimdışı aktiviteleri artırın."
}

app = FastAPI()

class InputData(BaseModel):
    bsmas: int
    screentime: int

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/predict")
def predict_level(data: InputData):
    # Girişleri garanti Python int yap
    bsmas = int(data.bsmas)
    screentime = int(data.screentime)

    input_array = [[bsmas, screentime]]
    pred = model.predict(input_array)[0]

    # NumPy tiplerini düz Python string’e çevir
    level = str(pred)

    suggestion = recommendations.get(level, "Öneri bulunamadı.")
    return {
        "level": level,
        "recommendation": suggestion
    }
