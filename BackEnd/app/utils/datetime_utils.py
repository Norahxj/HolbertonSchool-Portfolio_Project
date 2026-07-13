from datetime import datetime, timezone
from zoneinfo import ZoneInfo


UTC = timezone.utc
RIYADH_TIMEZONE = ZoneInfo("Asia/Riyadh")


def utc_now():
    return datetime.now(UTC)


def riyadh_now():
    return utc_now().astimezone(
        RIYADH_TIMEZONE
    )


def riyadh_today():
    return riyadh_now().date()


def riyadh_weekday():
    return riyadh_now().weekday()