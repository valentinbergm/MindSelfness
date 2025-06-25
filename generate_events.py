import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random
import csv # Используем стандартный модуль csv для более надежной записи

# --- Конфигурация генерации данных `user_events` ---
NUM_USERS = 35000 
NUM_SESSIONS = 100000 # Примерное количество сессий
EVENTS_PER_SESSION_RANGE = (2, 10) # Каждая сессия будет иметь от 2 до 10 событий
SESSION_DURATION_RANGE_SECONDS = (30, 3600) # Длительность сессии от 30 секунд до 1 часа
START_DATE = datetime(2023, 1, 1)
END_DATE = datetime(2024, 12, 31)

EVENT_NAME_WEIGHTS = {
    'app_open': 0.25, 'screen_view': 0.20, 'course_started': 0.10, 'lesson_completed': 0.10,
    'mood_logged': 0.10, 'ai_chat_started': 0.05, 'routine_created': 0.05, 'routine_completed': 0.05,
    'premium_feature_used': 0.05, 'subscription_purchased': 0.03, 'subscription_renewed': 0.01,
    'subscription_cancelled': 0.01
}
COURSE_IDS = [f'course_{i}' for i in range(1, 11)] 
LESSON_IDS = [f'lesson_{i}' for i in range(1, 51)] 
MOOD_SCORES = [f'score_{i}' for i in range(1, 6)] # Только score_N, без русских букв

# --- Генерация таблицы `user_events` ---
print("Генерация 'user_events.csv' (исправлено)...")
events_data = []
current_event_id = 1

# Шаг 1: Генерируем сессии
sessions_list = []
for i in range(1, NUM_SESSIONS + 1):
    session_user_id = random.randint(1, NUM_USERS)
    session_duration_seconds = random.randint(*SESSION_DURATION_RANGE_SECONDS)
    
    # Случайное время начала сессии в общем диапазоне
    session_start_timestamp = START_DATE + timedelta(seconds=random.randint(0, int((END_DATE - START_DATE).total_seconds())))
    session_end_timestamp = session_start_timestamp + timedelta(seconds=session_duration_seconds)

    # Убедимся, что сессия не выходит за END_DATE
    if session_end_timestamp > END_DATE:
        session_end_timestamp = END_DATE
        session_duration_seconds = int((session_end_timestamp - session_start_timestamp).total_seconds())
        if session_duration_seconds < EVENTS_PER_SESSION_RANGE[0]: # Если длительность стала слишком короткой, пропускаем
             continue

    sessions_list.append({
        'session_id': i,
        'user_id': session_user_id,
        'start_time': session_start_timestamp,
        'end_time': session_end_timestamp,
        'duration_seconds': session_duration_seconds
    })

# Шаг 2: Генерируем события внутри каждой сессии
for session in sessions_list:
    num_events_in_session = random.randint(*EVENTS_PER_SESSION_RANGE)
    
    # Распределяем события равномерно по длительности сессии
    time_intervals = [random.uniform(0, session['duration_seconds']) for _ in range(num_events_in_session)]
    time_intervals.sort() # Упорядочиваем, чтобы event_timestamp шли по возрастанию

    for j in range(num_events_in_session):
        event_offset_seconds = time_intervals[j]
        event_timestamp = session['start_time'] + timedelta(seconds=event_offset_seconds)
        
        event_name = random.choices(list(EVENT_NAME_WEIGHTS.keys()), weights=list(EVENT_NAME_WEIGHTS.values()))[0]
        
        event_detail = '' 
        if event_name == 'course_started':
            event_detail = random.choice(COURSE_IDS)
        elif event_name == 'lesson_completed':
            event_detail = random.choice(LESSON_IDS)
        elif event_name == 'mood_logged':
            event_detail = random.choice(MOOD_SCORES) # Только score_N
        
        events_data.append({
            'event_id': current_event_id,
            'user_id': session['user_id'],
            'event_timestamp': event_timestamp.strftime('%Y-%m-%d %H:%M:%S'),
            'event_name': event_name,
            'event_detail': event_detail,
            'session_id': session['session_id'], # Теперь session_id повторяется для событий одной сессии
            'session_duration_seconds': '' # Это поле оставим пустым, будем рассчитывать позже
        })
        current_event_id += 1

df_events = pd.DataFrame(events_data)
df_events.to_csv('user_events.csv', sep=',', index=False, encoding='utf-8', quoting=csv.QUOTE_NONNUMERIC) 

print(f"Таблица 'user_events.csv' с {len(df_events)} записями (из {NUM_SESSIONS} сессий) успешно сгенерирована и сохранена.")
print("\nГенерация 'user_events.csv' завершена. Теперь сессии должны иметь реальную длительность.")
