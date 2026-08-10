enum AddTaskWeekDay {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
}

extension AddTaskWeekDayBackendValue on AddTaskWeekDay {
  int get backendValue {
    switch (this) {
      case AddTaskWeekDay.monday:
        return 0;
      case AddTaskWeekDay.tuesday:
        return 1;
      case AddTaskWeekDay.wednesday:
        return 2;
      case AddTaskWeekDay.thursday:
        return 3;
      case AddTaskWeekDay.friday:
        return 4;
      case AddTaskWeekDay.saturday:
        return 5;
      case AddTaskWeekDay.sunday:
        return 6;
    }
  }

  static AddTaskWeekDay fromBackend(int? value) {
    switch (value) {
      case 0:
        return AddTaskWeekDay.monday;
      case 1:
        return AddTaskWeekDay.tuesday;
      case 2:
        return AddTaskWeekDay.wednesday;
      case 3:
        return AddTaskWeekDay.thursday;
      case 4:
        return AddTaskWeekDay.friday;
      case 5:
        return AddTaskWeekDay.saturday;
      case 6:
      default:
        return AddTaskWeekDay.sunday;
    }
  }
}
