import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

# --- Конфигурация генерации данных `users` ---
NUM_USERS = 35000
START_DATE = datetime(2023, 1, 1)
END_DATE = datetime(2024, 12, 31)

# Веса для распределения категориальных данных
COUNTRY_WEIGHTS = {'USA': 0.40, 'Germany': 0.20, 'Ukraine': 0.15, 'UK': 0.10, 'Canada': 0.10, 'Australia': 0.05}
DEVICE_TYPE_WEIGHTS = {'Mobile': 0.70, 'Tablet': 0.15, 'Web': 0.15}
ACQUISITION_CHANNEL_WEIGHTS = {'Organic': 0.45, 'Paid Ad': 0.35, 'Social Media': 0.15, 'Referral': 0.05}
SUBSCRIPTION_STATUS_WEIGHTS = {'Free': 0.60, 'Premium': 0.30, 'Trial': 0.10}
AGE_GROUP_WEIGHTS = {'25-34': 0.30, '18-24': 0.25, '35-44': 0.25, '45+': 0.20}
GENDER_WEIGHTS = {'Female': 0.55, 'Male': 0.40, 'Other': 0.05}

# --- Генерация таблицы `users` ---
print("Генерация таблицы 'users'...")
users_data = []
for i in range(1, NUM_USERS + 1):
    user_id = i
    registration_date = START_DATE + timedelta(days=random.randint(0, (END_DATE - START_DATE).days))
    
    country = random.choices(list(COUNTRY_WEIGHTS.keys()), weights=list(COUNTRY_WEIGHTS.values()))[0]
    device_type = random.choices(list(DEVICE_TYPE_WEIGHTS.keys()), weights=list(DEVICE_TYPE_WEIGHTS.values()))[0]
    acquisition_channel = random.choices(list(ACQUISITION_CHANNEL_WEIGHTS.keys()), weights=list(ACQUISITION_CHANNEL_WEIGHTS.values()))[0]
    subscription_status = random.choices(list(SUBSCRIPTION_STATUS_WEIGHTS.keys()), weights=list(SUBSCRIPTION_STATUS_WEIGHTS.values()))[0]

    # Логика для last_active_date
    last_active_date_candidate = None
    if subscription_status == 'Premium' or random.random() < 0.4: 
        start_period = max(registration_date, END_DATE - timedelta(days=90))
        end_period = END_DATE
    else: 
        start_period = registration_date
        end_period = min(END_DATE - timedelta(days=91), END_DATE) 

    if start_period > end_period:
        last_active_date_candidate = registration_date 
    else:
        days_diff = (end_period - start_period).days
        if days_diff >= 0:
            last_active_date_candidate = start_period + timedelta(days=random.randint(0, days_diff))
        else:
            last_active_date_candidate = registration_date 

    if random.random() < 0.05: # 5% NULL
        last_active_date = None
    else:
        last_active_date = last_active_date_candidate

    # age_group и gender с NULL
    age_group = random.choices(list(AGE_GROUP_WEIGHTS.keys()), weights=list(AGE_GROUP_WEIGHTS.values()))[0]
    if random.random() < 0.07: # 7% NULL
        age_group = None
    
    gender = random.choices(list(GENDER_WEIGHTS.keys()), weights=list(GENDER_WEIGHTS.values()))[0]
    if random.random() < 0.05: # 5% NULL
        gender = None

    users_data.append({
        'user_id': user_id,
        'registration_date': registration_date.strftime('%Y-%m-%d'),
        'country': country,
        'device_type': device_type,
        'acquisition_channel': acquisition_channel,
        'subscription_status': subscription_status,
        'last_active_date': last_active_date.strftime('%Y-%m-%d') if last_active_date else '',
        'age_group': age_group if age_group else '',
        'gender': gender if gender else ''
    })

df_users = pd.DataFrame(users_data)
# Изменено: разделитель на запятую, quotation на QUOTE_NONNUMERIC
df_users.to_csv('users.csv', sep=',', index=False, encoding='utf-8', quoting=1) # quoting=1 для QUOTE_NONNUMERIC
print(f"Таблица 'users' с {len(df_users)} записями успешно сгенерирована и сохранена в 'users.csv'.")
print("Генерация 'users.csv' завершена.")
