import pandas as pd
import numpy as np
from sklearn.tree import DecisionTreeClassifier
import joblib


df = pd.read_excel("/Users/osx/Desktop/dataset.xlsx", sheet_name="Database completo SM adolesc.")
data = df[['TOT_BSMAS']].copy()


np.random.seed(42)
data['ScreenTime'] = np.random.randint(1, 16, size=len(data))

def determine_level(row):
    if row['TOT_BSMAS'] <= 12 and row['ScreenTime'] <= 4:
        return 'Düşük'
    elif row['TOT_BSMAS'] <= 18 and row['ScreenTime'] <= 10:
        return 'Orta'
    else:
        return 'Yüksek'

data['Level'] = data.apply(determine_level, axis=1)


X = data[['TOT_BSMAS', 'ScreenTime']]
y = data['Level']
model = DecisionTreeClassifier(random_state=42)
model.fit(X, y)


joblib.dump(model, "decision_tree_model_v3.pkl")
print("✅ Model başarıyla yeniden eğitildi ve kaydedildi.")
