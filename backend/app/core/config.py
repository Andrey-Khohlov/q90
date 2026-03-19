from pydantic import SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict
from pathlib import Path
import logging


from app.core import logging_config

logger = logging.getLogger(__name__)

BASE_DIR = Path(__file__).parent.parent.parent

logger.debug(f'Looking for .env at: {BASE_DIR / ".env"}')
logger.debug(f'File exists: {(BASE_DIR / ".env").exists()}')


class Settings(BaseSettings):
    DB_HOST: str
    DB_PORT: int
    DB_USER: str
    DB_PASS: str
    DB_NAME: str
    api_key_mistral: SecretStr
    OAUTH_GOOGLE_CLIENT_SECRET: str
    OAUTH_GOOGLE_CLIENT_ID: str
    OAUTH_GITHUB_CLIENT_SECRET: str
    OAUTH_GITHUB_CLIENT_ID: str
    DEBUG: bool = False

    model_config = SettingsConfigDict(
        env_file=BASE_DIR / ".env",  # сначала ищет в корне проекта
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()
