import uuid

from sqlalchemy import ForeignKey, CheckConstraint, String, Text
from sqlalchemy.org import Mapped, mapped_column, relationship

from app.db.base import UUIDPrimaryKeyMixin, TimestampMixin, Base