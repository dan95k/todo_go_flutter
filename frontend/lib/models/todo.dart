enum Urgency { low, medium, high }

class Todo {
  int? id;
  String? text;
  int? finished;
  Urgency? urgency;
  Todo(
      {required this.id,
      required this.text,
      required this.urgency,
      required this.finished});

  Todo.fromJson(Map<String, dynamic> json) {
    id = json["Id"];
    text = json["Text"];
    finished = json["Finished"];
    urgency = _parseUrgency(json["Urgency"]);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data['Text'] = text;
    data['Done'] = finished;
    data['Urgency'] = urgency;
    return data;
  }

  Urgency _parseUrgency(int urgency) {
    switch (urgency) {
      case 1:
        return Urgency.low;
      case 2:
        return Urgency.medium;
      case 3:
        return Urgency.high;
      default:
        return Urgency.low;
    }
  }
}
