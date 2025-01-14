library miriwell_nhis_scrapper;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'package:miriwell_nhis_scrapper/_types.dart';
import 'package:miriwell_nhis_scrapper/nhis_auth_type.dart';
import 'package:miriwell_nhis_scrapper/nhis_result.dart';

// ignore: constant_identifier_names
const String _API_HOST = "https://api.miriwell.com/api/";

// ignore: constant_identifier_names
const Map<String, String> _API_ENDPOINT = {
  'startAuth': "v2/nhis/start_auth",
  'afterAuth': "v2/nhis/after_auth"
};

class MiriwellNHISScrapper {
  String _authToken;

  UserInfo _userInfo;

  UserInfo get userInfo => _userInfo;

  NHISAuthType _authType;

  dynamic _authData;

  final _cookieJar = CookieJar();

  /* result */
  List<NationalScreeningData> _screeningDataList = [];
  List<MedicalTreatmentData> _medicalTreatmentDataList = [];
  /* */

  MiriwellNHISScrapper._internal(
      this._authToken, this._authType, this._userInfo);

  factory MiriwellNHISScrapper(
      {required String authToken,
      required NHISAuthType authType,
      required String name,
      required String phone,
      required String birthday}) {
    return MiriwellNHISScrapper._internal(
        authToken, authType, UserInfo(name, phone, birthday));
  }

  void _saveCookieIntoJar(CookieJar cookieJar, SetCookieInfo cInfo) {
    final domain = cInfo.domain ?? '';
    final uri = Uri.parse(domain);

    final cookieParts = cInfo.cookie.split('=');
    final name = cookieParts.first;
    final value =
        cookieParts.length > 1 ? cookieParts.sublist(1).join('=') : '';

    final cookie = Cookie(name, value);

    if (cInfo.options != null) {
      final opts = cInfo.options!;

      if (opts['path'] != null) {
        cookie.path = opts['path'];
      }

      if (opts['expires'] != null) {
        try {
          cookie.expires = HttpDate.parse(opts['expires'] as String);
        } catch (_) {}
      }

      if (opts['httpOnly'] != null) {}
    }

    cookieJar.saveFromResponse(uri, [cookie]);
  }

  String _addQueryString(String url, Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return url;
    final uri = Uri.parse(url);
    final newQueryParameters = Map<String, dynamic>.from(uri.queryParameters)
      ..addAll(params.map((k, v) => MapEntry(k, v.toString())));
    return uri.replace(queryParameters: newQueryParameters).toString();
  }

  Future<CrawlStepResult> _doRequests({
    required String startEndpoint,
    dynamic initialAdditionalData,
  }) async {
    try {
      final miriwellDio = Dio();
      final scrapDio = Dio();
      scrapDio.interceptors.add(CookieManager(_cookieJar));

      String? nextEndpoint = startEndpoint;
      dynamic prevData;

      CrawlStepResult result = CrawlStepResult(
        data: null,
        additionalData: initialAdditionalData,
      );

      while (nextEndpoint != null && nextEndpoint.isNotEmpty) {
        final response = await miriwellDio.post('$_API_HOST$nextEndpoint',
            data: {
              'authType': _authType.value,
              'crawlPayload': prevData,
              'additionalData': result.additionalData,
              'userInfo': _userInfo.toJson()
            },
            options: Options(headers: {"Authorization": 'Bearer $_authToken'}));

        final stepResponse = CrawlStepResponse.fromJson(
            response.data['data'] as Map<String, dynamic>);

        final List<Future<Response>> futures = [];
        final List<dynamic> accumulated = [];
        prevData = null;

        for (final req in stepResponse.requests) {
          if (stepResponse.parallel != true && req.setCookie != null) {
            for (final cookieInfo in req.setCookie!) {
              _saveCookieIntoJar(_cookieJar, cookieInfo);
            }
          }

          final options = Options(
            method: req.method,
            headers: req.headers,
          );

          final String requestUrl = (req.method.toUpperCase() == 'GET')
              ? _addQueryString(req.url, req.body)
              : req.url;

          if (stepResponse.parallel ?? false) {
            if (req.method.toUpperCase() == 'GET') {
              futures.add(scrapDio.request(requestUrl, options: options));
            } else {
              futures.add(scrapDio.request(requestUrl,
                  data: req.body, options: options));
            }
          } else {
            late Response singleResponse;
            if (req.method.toUpperCase() == 'GET') {
              singleResponse =
                  await scrapDio.request(requestUrl, options: options);
            } else {
              singleResponse = await scrapDio.request(requestUrl,
                  data: req.body, options: options);
            }

            dynamic singleData = singleResponse.data;
            try {
              singleData = jsonDecode(singleData);
            } catch (_) {}

            if (stepResponse.accumulate ?? false) {
              accumulated.add(singleData);
            } else {
              prevData = singleData;
            }
          }
        }

        if (stepResponse.parallel ?? false) {
          final parallelResponses = await Future.wait(futures);
          final parallelData = parallelResponses.map((r) => r.data).toList();
          prevData = parallelData;
        } else if (stepResponse.accumulate ?? false) {
          prevData = accumulated;
        }

        nextEndpoint = stepResponse.nextEndpoint;
        result = CrawlStepResult(
          data: prevData,
          additionalData: stepResponse.additionalData,
        );

        if (result.additionalData != null &&
            result.additionalData["nationalScreenings"] != null) {
          _screeningDataList =
              (result.additionalData["nationalScreenings"] as List<dynamic>)
                  .map((nationalScreening) => NationalScreeningData.fromJson(
                      nationalScreening as Map<String, dynamic>))
                  .toList();
        }

        if (result.additionalData != null &&
            result.additionalData['medicalTreatmentData'] != null) {
          _medicalTreatmentDataList =
              (result.additionalData["medicalTreatmentData"] as List<dynamic>)
                  .map((medicalTreatment) => MedicalTreatmentData.fromJson(
                      medicalTreatment as Map<String, dynamic>))
                  .toList();
        }
      }

      return result;
    } catch (err) {
      rethrow;
    }
  }

  Future<void> startAuth() async {
    CrawlStepResult response = await _doRequests(
      startEndpoint: _API_ENDPOINT['startAuth']!,
    );

    _authData = response.additionalData;
  }

  Future<NHISScrapResult> afterAuth() async {
    await _doRequests(
        startEndpoint: _API_ENDPOINT['afterAuth']!,
        initialAdditionalData: _authData);

    return NHISScrapResult(_screeningDataList, _medicalTreatmentDataList);
  }
}
