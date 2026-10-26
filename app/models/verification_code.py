import uuid
from datetime import datetime

from sqlalchemy import CheckConstraint, ForeignKey, Index, SmallInteger, String, text
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, CreatedAtMixin, UUIDPrimaryKeyMixin


class VerificationCode(UUIDPrimaryKeyMixin, CreatedAtMixin, Base):
    __tablename__ = "verification_codes"

    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE")
    )
    channel: Mapped[str] = mapped_column(String(10))
    target: Mapped[str] = mapped_column(String(255))
    purpose: Mapped[str] = mapped_column(String(30))
    code_hash: Mapped[str] = mapped_column(String(128))
    attempts: Mapped[int] = mapped_column(
        SmallInteger, default=0, server_default=text("0")
    )
    expires_at: Mapped[datetime]
    consumed_at: Mapped[datetime | None]

    __table_args__ = (
        CheckConstraint("channel IN ('EMAIL', 'PHONE')", name="channel"),
        CheckConstraint(
            "purpose IN ('VERIFY_CONTACT', 'LOGIN', 'PASSWORD_RESET')",
            name="purpose",
        ),
        CheckConstraint("attempts >= 0", name="attempts_nonneg"),
        Index(
            "ix_verification_codes_user_purpose_created",
            "user_id",
            "purpose",
            text("created_at DESC"),
        ),
    )