enum ChildFormFieldErrorCode {
  nameRequired,
  nameTooShort,
  nameTooLong,
  nameLettersOnly,
  birthDateRequired,
  invalidChildAge,
  invalidPhone,
}

enum ChildFormErrorCode {
  addChild,
  updateChild,
  childNotIdentified,
  phoneAlreadyUsed,
  parentNotLinkedToFamily,
  parentAccessRequiredForAdd,
  parentAccessRequiredForEdit,
  parentNotFound,
  childNotFound,
  couldNotCreateChild,
  couldNotUpdateChild,
  unexpectedAddError,
  unexpectedUpdateError,
}
