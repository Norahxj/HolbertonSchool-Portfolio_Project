String formatDate(DateTime? date) {
  if (date == null) return '';

  return '${date.day}/${date.month}/${date.year}';
}