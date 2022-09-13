class ForcastDaysModel {
  var _dateTime;
  var _temp;
  String _main;
  String _description;
  String _icon;

  ForcastDaysModel(
      this._dateTime, this._temp, this._main, this._description, this._icon);

  get dateTime => _dateTime;
  get temp => _temp;

  String get main => _main;
  String get description => _description;
  String get icon => _icon;
}
