class CurrentCityDataModel {
  String _cityName;
  var _lon;
  var _lat;
  String _main;
  String _discription;
  var _temp;
  var _temp_min;
  var _temp_max;
  var _pressure;
  var _humidity;
  var _windSpeed;
  var _dateTime;
  String _country;
  var _sunrise;
  var _sunset;
  String _icon;

  CurrentCityDataModel(
      this._cityName,
      this._lon,
      this._lat,
      this._main,
      this._discription,
      this._temp,
      this._temp_min,
      this._temp_max,
      this._pressure,
      this._humidity,
      this._windSpeed,
      this._dateTime,
      this._country,
      this._sunrise,
      this._sunset,
      this._icon);

  String get cityName => _cityName;
  get lon => _lon;
  get lat => _lat;
  String get main => _main;
  String get discription => _discription;
  get temp => _temp;
  get temp_min => _temp_min;
  get temp_max => _temp_max;
  get pressure => _pressure;
  get humidity => _humidity;
  get windSpeed => _windSpeed;
  get dateTime => _dateTime;
  String get country => _country;
  get sunrise => _sunrise;
  get sunset => _sunset;
  String get icon => _icon;
}
