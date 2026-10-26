from decimal import Decimal
from sqlalchemy import CheckConstraint, String, Index, Numeric
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin, UUIDPrimaryKeyMixin

class Location(UUIDPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__="locations"

    label: Mapped[str | None] = mapped_column(String(200))
    addres_line: Mapped[str | None] = mapped_column(String(255))
    city: Mapped[str | None] = mapped_column(String(100))
    state: Mapped[str | None] = mapped_column(String(100))
    country: Mapped[str] = mapped_column(String(2))
    lattitude: Mapped[Decimal | None] = mapped_column(Numeric(9, 6))
    longitude: Mapped[Decimal | None] = mapped_column(Numeric(9, 6))
    google_place_id: Mapped[str | None] = mapped_column(String(255))

    __table_args__=(
        CheckConstraint(
            "(latitude IS NULL) = (longitude IS NULL)",
            name="coords_pair"
        ),
        CheckConstraint(
            "latitude BETWEN -90 AND 90 AND longitude BETWEN -180 AND 180",
            name="coords_range"
        ),
        CheckConstraint("country ~ '^[A-Z]{2}$'", name="country_format"),
        Index("ix_locations_country_state_city", "country", "state", "city"),
    )

