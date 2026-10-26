from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "LinkedArt"
    enviroment: str = "development"
    debug: bool = False

    database_url: str
    secret_key: str
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30

    cors_origins: list[str] = []

@lru_cache
def get_settings() -> Settings:
    return Settings()