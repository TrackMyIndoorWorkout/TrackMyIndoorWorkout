// upload.dart

class UploadActivity {
  int activityId;
  String externalId;
  int id;
  String error;
  String status;

  UploadActivity(
      {this.activityId, this.externalId, this.id, this.error, this.status});

  UploadActivity.fromJson(Map<String, dynamic> json) {
    activityId = json['activity_id'];
    externalId = json['external_id'];
    id = json['id'];
    error = json['error'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['activity_id'] = this.activityId;
    data['external_id'] = this.externalId;
    data['id'] = this.id;
    data['error'] = this.error;
    data['status'] = this.status;
    return data;
  }
}

class ResponseUploadActivity {
  int id;
  String externalId;
  String error;
  String status;
  int activityId;

  ResponseUploadActivity(
      this.id, this.externalId, this.error, this.status, this.activityId);

  ResponseUploadActivity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    externalId = json['external_id'];
    error = json['error'];
    status = json['status'];
    activityId = json['activity_id'];
  }
}
