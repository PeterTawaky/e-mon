import 'package:e_mon_app/core/utils/app_ios_icons.dart';
import 'api_error_model.dart';
import 'local_status_codes.dart';

class ApiErrorFactory {
  static ApiErrorModel get defaultError => ApiErrorModel(
    message: "Something went wrong",
    icon: AppIosIcons.error,
    statusCode: LocalStatusCodes.defaultError,
  );
  static ApiErrorModel get badResponseWithoutCode => ApiErrorModel(
    //when the server doesn't send status code in the response
    message: "Something went wrong",
    icon: AppIosIcons.error,
    statusCode: LocalStatusCodes.badResponse,
  );
  static ApiErrorModel get noInternetConnection => ApiErrorModel(
    message: "Server Connection Error",
    icon: AppIosIcons.noConnection,
    statusCode: LocalStatusCodes.connectionError,
  );
  static ApiErrorModel get connectionTimeout => ApiErrorModel(
    message: "Connection timed out. Please try again.",
    icon: AppIosIcons.timeout,
    statusCode: LocalStatusCodes.connectionTimeout,
  );
  static ApiErrorModel get sendTimeout => ApiErrorModel(
    message: "Couldn't send your request. Please try again.",
    icon: AppIosIcons.send,
    statusCode: LocalStatusCodes.sendTimeout,
  );
  static ApiErrorModel get receiveTimeout => ApiErrorModel(
    message: "Taking too long to load. Please try again later.",
    icon: AppIosIcons.receive,
    statusCode: LocalStatusCodes.receiveTimeout,
  );
  static ApiErrorModel get badCertificate => ApiErrorModel(
    message: "Security issue detected. Please try again later.",
    icon: AppIosIcons.security,
    statusCode: LocalStatusCodes.badCertificate,
  );
}
