enum NHISAuthType {
  naver,
  kakao,
}

extension NHISAuthTypeExtension on NHISAuthType {
  int get value {
    switch (this) {
      case NHISAuthType.naver:
        return 1;
      case NHISAuthType.kakao:
        return 2;
    }
  }

  String get name {
    switch (this) {
      case NHISAuthType.naver:
        return 'Naver';
      case NHISAuthType.kakao:
        return 'Kakao';
    }
  }
}
