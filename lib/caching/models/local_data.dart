class BaseLocal {

  BaseLocal({required this.time, required this.model});

  BaseLocal.fromJson(final Map<String, dynamic> json) {
    time = DateTime.parse(json["time"]);
    model = json["model"];
  }
  late DateTime time;
  late String model;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["time"] = time.toString();
    data["model"] = model;
    return data;
  }
}
