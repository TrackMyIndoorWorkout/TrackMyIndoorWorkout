class UploadActivity {
  late int activityId;
  late String externalId;
  late int id;
  late String error;
  late String status;

  UploadActivity(this.activityId, this.externalId, this.id, this.error, this.status);

  UploadActivity.fromJson(Map<String, dynamic> json) {
    activityId = json['activity_id'];
    externalId = json['external_id'];
    id = json['id'];
    error = json['error'];
    status = json['status'];
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
  late int id;
  late String externalId;
  late String error;
  late String status;
  late int activityId;

  ResponseUploadActivity(this.id, this.externalId, this.error, this.status, this.activityId);

  ResponseUploadActivity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    externalId = json['external_id'];
    error = json['error'];
    status = json['status'];
    activityId = json['activity_id'];
  }
}
