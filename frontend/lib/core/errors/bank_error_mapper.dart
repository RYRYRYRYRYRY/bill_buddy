
import 'package:dio/dio.dart';

import 'bank_error.dart';

class BankErrorMapper {
  static BankError map(Object error) {
    if (error is BankError) {
      return error;
    }

    if (error is DioException) {
      return _mapDioError(error);
    }

    return const BankError(
      code: 'UNKNOWN_ERROR',
      message:
          'Something went wrong. Please try again.',
    );
  }

  static BankError _mapDioError(
    DioException error,
  ) {
    final statusCode =
        error.response?.statusCode;

    final data = error.response?.data;

    String? serverCode;
    String? serverMessage;

    if (data is Map<String, dynamic>) {
      final errorData = data['error'];

      if (errorData is Map<String, dynamic>) {
        serverCode =
            errorData['code']?.toString();

        serverMessage =
            errorData['message']?.toString();
      }
    }

    switch (serverCode) {
      case 'EMAIL_ALREADY_EXISTS':
        return const BankError(
          code: 'EMAIL_ALREADY_EXISTS',
          message:
              'An account with this email already exists.',
        );

      case 'INVALID_CREDENTIALS':
        return const BankError(
          code: 'INVALID_CREDENTIALS',
          message:
              'The email or password is incorrect.',
        );

      case 'VALIDATION_ERROR':
        return const BankError(
          code: 'VALIDATION_ERROR',
          message:
              'Please check the information you entered.',
        );

      case 'INVALID_REFRESH_TOKEN':
      case 'REFRESH_TOKEN_EXPIRED':
        return const BankError(
          code: 'SESSION_EXPIRED',
          message:
              'Your session has expired. Please log in again.',
        );

      case 'UNAUTHORIZED':
        return const BankError(
          code: 'UNAUTHORIZED',
          message:
              'Your session is no longer valid. Please log in again.',
        );

      case 'USER_NOT_FOUND':
        return const BankError(
          code: 'USER_NOT_FOUND',
          message:
              'We could not find your account.',
        );
    }

    switch (statusCode) {
      case 400:
        return const BankError(
          code: 'BAD_REQUEST',
          message:
              'Please check the information you entered.',
        );

      case 401:
        return const BankError(
          code: 'UNAUTHORIZED',
          message:
              'Your session is no longer valid. Please log in again.',
        );

      case 403:
        return const BankError(
          code: 'FORBIDDEN',
          message:
              'You are not allowed to perform this action.',
        );

      case 404:
        return const BankError(
          code: 'NOT_FOUND',
          message:
              'The requested information could not be found.',
        );

      case 409:
        return const BankError(
          code: 'CONFLICT',
          message:
              'This action conflicts with existing information.',
        );

      case 429:
        return const BankError(
          code: 'RATE_LIMITED',
          message:
              'Too many attempts. Please wait a moment and try again.',
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return const BankError(
          code: 'SERVER_ERROR',
          message:
              'We are having trouble connecting to BillBuddy. Please try again shortly.',
        );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const BankError(
        code: 'TIMEOUT',
        message:
            'The request took too long. Please check your connection and try again.',
      );
    }

    if (error.type ==
        DioExceptionType.connectionError) {
      return const BankError(
        code: 'CONNECTION_ERROR',
        message:
            'Unable to connect to BillBuddy. Please check your internet connection.',
      );
    }

    // We deliberately do not expose serverMessage
    // or Dio's raw exception to the user.
    return const BankError(
      code: 'UNKNOWN_ERROR',
      message:
          'Something went wrong. Please try again.',
    );
  }
}
