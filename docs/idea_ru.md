Разрабатывается онлайн-сервис: 
# база данных кофе, обжарщиков, фермеров, пользовательских оценок и чат обсуждения кофе.

# Technology Stack
- Backend: FastAPI (Python)
- Frontend: Flet (Python-based UI framework)
- Database: PostgreSQL with SQLAlchemy ORM
- Containerization: Docker & Docker Compose
- Migration: Alembic
- Asynchronous Processing: asyncio

# Цели:
- получение экспертной независимой экспертной оценкти сообщества для обжареного кофе
- оценка сообществом кофе
- общение: обсуждения под постом с описанием оценки кофе, общий чат
- получение рекомендаций 
- отслеживание вкусового опыта друзей
- дневник заварок для отслеживания идивидуального опыта и влияния способов заваривания на вкус
- прослеживаемость кофе
- сравнение качеста и цены на кофе
- связь фермеров, обжарщиков и любителей кофе 

# Сервисы:
- Coffee database with detailed information (origin, processing, tasting notes, etc.)
- User accounts and profiles
- регистрация через соцсети OAuth 2.0
- Rating (шкалы: 0-1, 1-3, 1-5, 1-10, 1-100) and review system
- Discussion forums/chats about specific coffees
- Search and filtering capabilities
- ИИ заполнение карточки кофе по ссылке
- модерация сообщений (бот, кнопка пожаловаться)
- локализация (фронт, базы кофе, сообщений)