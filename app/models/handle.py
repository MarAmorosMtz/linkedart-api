import uuid

from sqlalchemy import CheckConstraint, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, CreatedAtMixin


class Handle(CreatedAtMixin, Base):
    __tablename__ = "handles"

    username: Mapped[str] = mapped_column(String(30), primary_key=True)
    user_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), unique=True
    )
    organization_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("organizations.id", ondelete="CASCADE"), unique=True
    )

    __table_args__ = (
        CheckConstraint("username ~ '^[a-z0-9_]{3,30}$'", name="username_format"),
        CheckConstraint("num_nonnulls(user_id, organization_id) = 1", name="owner"),
    )