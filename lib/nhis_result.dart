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

  Map<String, dynamic> toJson() {
    return {
      'institution': institution,
      'date': date,
      'type': type,
      'detail': detail
    };
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

  Map<String, dynamic> toJson() {
    return {'date': date, 'recipe': recipe, 'quantity': quantity};
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

  Map<String, dynamic> toJson() {
    return {
      'institution': institution,
      'date': date,
      'type': type,
      'detailType': detailType,
      'location': location,
      'detail': detail.map((d) => d.toJson()).toList()
    };
  }
}

class NHISScrapResult {
  List<NationalScreeningData> screeningDataList;
  List<MedicalTreatmentData> medicalTreatmentDataList;

  NHISScrapResult(this.screeningDataList, this.medicalTreatmentDataList);

  Map<String, dynamic> toJson() {
    return {
      'screeningDataList': screeningDataList.map((s) => s.toJson()).toList(),
      'medicalTreatmentDataList':
          medicalTreatmentDataList.map((m) => m.toJson()).toList()
    };
  }
}
