class NationalScreeningData {
  String institution;
  String date;
  String type;
  dynamic detail;

  NationalScreeningData(this.institution, this.date, this.type, this.detail);

  factory NationalScreeningData.fromJson(Map<String, dynamic> json) {
    return NationalScreeningData(
        json['institution'], json['date'], json['type'], json['detail']);
  }
}

class MedicalTreatmentDetail {
  String date;
  String recipe;
  String quantity;

  MedicalTreatmentDetail(this.date, this.recipe, this.quantity);

  factory MedicalTreatmentDetail.fromJson(Map<String, dynamic> json) {
    return MedicalTreatmentDetail(
        json['date'], json['recipe'], json['quantity']);
  }
}

class MedicalTreatmentData {
  String institution;
  String date;
  String type;
  String detailType;
  String? location;
  List<MedicalTreatmentDetail> detail;

  MedicalTreatmentData(this.institution, this.date, this.type, this.detailType,
      this.location, this.detail);

  factory MedicalTreatmentData.fromJson(Map<String, dynamic> json) {
    return MedicalTreatmentData(
        json['institution'],
        json['date'],
        json['type'],
        json['detailType'],
        json['location'],
        (json['detail'] as List<dynamic>)
            .map((detailJson) => MedicalTreatmentDetail.fromJson(detailJson))
            .toList());
  }
}

class NHISScrapResult {
  List<NationalScreeningData> screeningDataList;
  List<MedicalTreatmentData> medicalTreatmentDataList;

  NHISScrapResult(this.screeningDataList, this.medicalTreatmentDataList);
}
