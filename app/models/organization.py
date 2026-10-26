import uuid
from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, CheckConstraint, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import UUIDPrimaryKeyMixin, TimestampMixin, Base

if TYPE_CHECKING:
    from app.models.locations import Location

class Organization(UUIDPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__="organizations"

    name: Mapped[str] = mapped_column(String(150))
    type: Mapped[str] = mapped_column(String(30))
    description: Mapped[str | None] = mapped_column(Text)
    website: Mapped[str | None] = mapped_column(String(500))
    profile_image: Mapped[str | None] = mapped_column(String(500))
    banner_image: Mapped[str | None] = mapped_column(String(500))
    location_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("locations.id", ondelete="SET NULL"), index=True
    )

    location: Mapped["Location | None"] = relationship()

    __table_args__=(
        CheckConstraint(
            "type IN ('COMPANY', 'GROUP', 'INSTITUTION', 'NON_PROFIT', 'OTHER')",
            name="type",
        ),
    )


