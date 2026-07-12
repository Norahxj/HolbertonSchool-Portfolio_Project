from calendar import monthrange


def is_task_due_on_date(
    task_frequency,
    recurrence_day,
    target_date
):
    if task_frequency == "DAILY":
        return True

    if task_frequency == "WEEKLY":
        return recurrence_day == target_date.weekday()

    if task_frequency == "MONTHLY":
        last_day_of_month = monthrange(
            target_date.year,
            target_date.month
        )[1]

        effective_day = min(
            recurrence_day,
            last_day_of_month
        )

        return target_date.day == effective_day

    return False