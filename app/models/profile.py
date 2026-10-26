import uuid
from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.location import Location
    from app.models.user import User

class Profile(TimestampMixin, Base):
    __tablename__="profiles"

    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE", primary_key=True)
    )
    name: Mapped[str] = mapped_column(String(100))
    bio: Mapped[str | None] = mapped_column(String(160))
    description: Mapped[str | None] = mapped_column(Text)
    profile_image: Mapped[str | None] = mapped_column(String(500))
    banner_image: Mapped[str | None] = mapped_column(String(500))
    location_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("locations.id", ondelete="SET NULL", index=True)
    )

    user: Mapped["User"] = relationship(back_populates="profile")
    location: Mapped["Location | None"] = relationship()