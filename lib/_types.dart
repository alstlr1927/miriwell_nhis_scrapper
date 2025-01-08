class UserInfo {
  final String name;
  final String phone;
  final String birthday;

  UserInfo(this.name, this.phone, this.birthday);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'birthday': birthday,
    };
  }
}

class CrawlStepResult {
  final dynamic data;

  final dynamic additionalData;

  CrawlStepResult({
    required this.data,
    this.additionalData,
  });
}

class SetCookieInfo {
  final String cookie;
  final String? domain;
  final Map<String, dynamic>? options;

  SetCookieInfo({
    required this.cookie,
    this.domain,
    this.options,
  });

  factory SetCookieInfo.fromJson(Map<String, dynamic> json) {
    return SetCookieInfo(
      cookie: json['cookie'] as String,
      domain: json['domain'] as String?,
      options: json['options'] as Map<String, dynamic>?,
    );
  }
}

class CrawlRequest {
  /// "GET" | "POST"
  final String method;
  final Map<String, dynamic>? headers;
  final String url;
  final dynamic body;
  final List<SetCookieInfo>? setCookie;

  CrawlRequest({
    required this.method,
    required this.url,
    this.headers,
    this.body,
    this.setCookie,
  });

  factory CrawlRequest.fromJson(Map<String, dynamic> json) {
    return CrawlRequest(
      method: json['method'] as String,
      headers: json['headers'] as Map<String, dynamic>?,
      url: json['url'] as String,
      body: json['body'],
      setCookie: (json['setCookie'] as List<dynamic>?)
          ?.map((c) => SetCookieInfo.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CrawlStepResponse {
  final String? nextEndpoint;
  final List<CrawlRequest> requests;
  final bool? parallel;
  final bool? accumulate;
  final dynamic additionalData;

  CrawlStepResponse({
    this.nextEndpoint,
    required this.requests,
    this.parallel,
    this.accumulate,
    this.additionalData,
  });

  factory CrawlStepResponse.fromJson(Map<String, dynamic> json) {
    final reqs = (json['requests'] as List<dynamic>)
        .map((r) => CrawlRequest.fromJson(r as Map<String, dynamic>))
        .toList();

    return CrawlStepResponse(
      nextEndpoint: json['nextEndpoint'] as String?,
      requests: reqs,
      parallel: json['parallel'] as bool?,
      accumulate: json['accumulate'] as bool?,
      additionalData: json['additionalData'],
    );
  }
}
