from app.models.user import User


def handler(nombre: str) -> User:
    return User(nombre)
