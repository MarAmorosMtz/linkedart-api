from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import CheckConstraint, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, TimestampMixin, UUIDPrimaryKeyMixin

if TYPE_CHECKING:
    from app.models.profile import Profile

class User(UUIDPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__="users"

    email: Mapped[str | None] = mapped_column(String(255), unique=True)
    phone_number: Mapped[str | None] = mapped_column(String(20), unique=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    email_verified_at: Mapped[datetime | None]
    phone_verified_at: Mapped[datetime | None]

    profile: Mapped["Profile"] = relationship(
        back_populates="user",
        uselist=False,
        cascade="all, delete-orphan",
        passive_deletes=True,
    )

    __table_args__=(
        CheckConstraint("email = lower(email)", name="email_lower"),
        CheckConstraint(
            "email IS NOT NULL OR phone_number IS NOT NULL", name="has_identifier"
        ),
        CheckConstraint(
            r"phone_number IS NULL OR phone_number ~ '^\+[1-9][0-9]{7,14}$'",
            name="phone_e164"
        ),
        CheckConstraint(
            "email_verified_at IS NULL OR email IS NOT NULL",
            name="verified_email"
        ),
        CheckConstraint(
            "phone_verified_at IS NULL OR phone_number IS NOT NULL",
            name="verified_phone"
        )
    )