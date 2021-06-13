class UploadActivity {
  int activityId = 0;
  String externalId = "";
  int id = 0;
  String error = "";
  String status = "";

  UploadActivity(this.activityId, this.externalId, this.id, this.error, this.status);

  UploadActivity.fromJson(Map<String, dynamic> json) {
    activityId = json['activity_id'] ?? 0;
    externalId = json['external_id'] ?? "";
    id = json['id'] ?? 0;
    error = json['error'] ?? "";
    status = json['status'] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': this.activityId,
      'external_id': this.externalId,
      'id': this.id,
      'error': this.error,
      'status': this.status,
    };
  }
}

class ResponseUploadActivity {
  int id = 0;
  String externalId = "";
  String error = "";
  String status = "";
  int activityId = 0;

  ResponseUploadActivity(this.id, this.externalId, this.error, this.status, this.activityId);

  ResponseUploadActivity.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    externalId = json['external_id'] ?? "";
    error = json['error'] ?? "";
    status = json['status'] ?? "";
    activityId = json['activity_id'] ?? 0;
  }
}
