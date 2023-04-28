class Temps {
  String name = '';
  String main = '';
  String description = '';
  String icon = '';
  var temp = 0.0;
  var pressure;
  var humidity;
  var temp_min;
  var temp_max;

  Temps();

  void fromJSON(Map map) {
    this.name = map["name"];
    List weather = map["weather"];
    Map mapWeather = weather[0];
    this.main = mapWeather["main"];
    this.description = mapWeather["description"];
    String monIcone = mapWeather["icon"];
    this.icon =
        "asset_store/${monIcone.replaceAll("d", "").replaceAll("n", "")}.png";

    Map main = map["main"];
    this.temp = main["temp"];
    this.pressure = main["pressure"];
    this.humidity = main["humidity"];
    this.temp_min = main["temp_min"];
    this.temp_max = main["temp_max"];
  }
}
