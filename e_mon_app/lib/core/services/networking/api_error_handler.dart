import 'package:dio/dio.dart';
import 'package:e_mon_app/core/utils/app_ios_icons.dart';
import 'api_error_factory.dart';
import 'api_error_model.dart';
import 'local_status_codes.dart';

class ApiErrorHandler {
  /// Extracts the `detail` field from the server response body.
  /// Falls back to [fallback] if no meaningful detail is present.
  static String _serverDetail(DioException e, String fallback) {
    try {
      final data = e.response?.data;
      if (data is Map) {
        final detail = data['detail'];
        if (detail is String && detail.isNotEmpty) return detail;
        // Pydantic validation error list format
        if (detail is List && detail.isNotEmpty) {
          final messages = detail
              .map((d) => d is Map ? d['msg']?.toString() ?? '' : d.toString())
              .where((s) => s.isNotEmpty)
              .join(', ');
          if (messages.isNotEmpty) return messages;
        }
      }
    } catch (_) {}
    return fallback;
  }

  static ApiErrorModel handle(dynamic e) {
    switch (e) {
      case DioException(:final DioExceptionType type):
        return switch (type) {
          DioExceptionType.connectionError =>
            ApiErrorFactory.noInternetConnection,
          DioExceptionType.connectionTimeout =>
            ApiErrorFactory.connectionTimeout,
          DioExceptionType.sendTimeout => ApiErrorFactory.sendTimeout,
          DioExceptionType.receiveTimeout => ApiErrorFactory.receiveTimeout,
          DioExceptionType.badCertificate => ApiErrorFactory.badCertificate,
          DioExceptionType.badResponse when e.response?.statusCode != null =>
            switch (e.response!.statusCode) {
              400 => ApiErrorModel(
                message: _serverDetail(e, "Something went wrong. Please try again."),
                icon: AppIosIcons.error,
                statusCode: 400,
              ),
              401 => ApiErrorModel(
                message: _serverDetail(e, "Please log in to continue."),
                icon: AppIosIcons.unauthorized,
                statusCode: 401,
              ),
              403 => ApiErrorModel(
                message: _serverDetail(e, "You don't have permission to access this."),
                icon: AppIosIcons.forbidden,
                statusCode: 403,
              ),
              404 => ApiErrorModel(
                message: _serverDetail(e, "The requested item was not found."),
                icon: AppIosIcons.notFound,
                statusCode: 404,
              ),
              409 => ApiErrorModel(
                message: _serverDetail(e, "This item already exists."),
                icon: AppIosIcons.duplicate,
                statusCode: 409,
              ),
              422 => ApiErrorModel(
                message: _serverDetail(e, "Please check your information and try again."),
                icon: AppIosIcons.warning,
                statusCode: 422,
              ),
              429 => ApiErrorModel(
                message: "Please wait a moment before trying again.",
                icon: AppIosIcons.rateLimit,
                statusCode: 429,
              ),
              500 => ApiErrorModel(
                message: "We're having some trouble. Please try again later.",
                icon: AppIosIcons.serverError,
                statusCode: 500,
              ),
              502 => ApiErrorModel(
                message: "We're experiencing technical issues. Please try again soon.",
                icon: AppIosIcons.cloudError,
                statusCode: 502,
              ),
              503 => ApiErrorModel(
                message: "Our service is currently unavailable. Please check back later.",
                icon: AppIosIcons.maintenance,
                statusCode: 503,
              ),
              504 => ApiErrorModel(
                message: "Request timed out. Please try again.",
                icon: AppIosIcons.timeout,
                statusCode: 504,
              ),
              _ => ApiErrorFactory.badResponseWithoutCode,
            },
          DioExceptionType.badResponse => ApiErrorModel(
            message: "Something went wrong. Please try again.",
            icon: AppIosIcons.warning,
            statusCode: LocalStatusCodes.badResponse,
          ),
          DioExceptionType.cancel => ApiErrorModel(
            message: "Request was cancelled. Please try again.",
            icon: AppIosIcons.cancelled,
            statusCode: LocalStatusCodes.cancel,
          ),
          DioExceptionType.unknown => ApiErrorModel(
            message: "Something went wrong. Please try again later.",
            icon: AppIosIcons.error,
            statusCode: LocalStatusCodes.unknown,
          ),
        };
      case Exception _:
        return ApiErrorFactory.defaultError;
      default:
        return ApiErrorFactory.defaultError;
    }
  }
}
