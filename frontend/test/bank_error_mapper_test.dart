import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/errors/bank_error.dart';
import 'package:frontend/core/errors/bank_error_mapper.dart';

void main() {
  group('BankErrorMapper', () {
    test('returns BankError unchanged', () {
      const original = BankError(code: 'TEST_ERROR', message: 'Test message');

      final result = BankErrorMapper.map(original);

      expect(result, same(original));
    });

    test('maps invalid credentials', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
          data: {
            'error': {
              'code': 'INVALID_CREDENTIALS',
              'message': 'Invalid credentials',
            },
          },
        ),
      );

      final result = BankErrorMapper.map(error);

      expect(result.code, 'INVALID_CREDENTIALS');
      expect(result.message, 'The email or password is incorrect.');
    });

    test('maps duplicate email', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/auth/register'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/register'),
          statusCode: 409,
          data: {
            'error': {
              'code': 'EMAIL_ALREADY_EXISTS',
              'message': 'Email already exists',
            },
          },
        ),
      );

      final result = BankErrorMapper.map(error);

      expect(result.code, 'EMAIL_ALREADY_EXISTS');
      expect(result.message, 'An account with this email already exists.');
    });

    test('maps unauthorized response', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      final result = BankErrorMapper.map(error);

      expect(result.code, 'UNAUTHORIZED');
    });

    test('maps rate limiting', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 429,
        ),
      );

      final result = BankErrorMapper.map(error);

      expect(result.code, 'RATE_LIMITED');
    });

    test('maps server error', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );

      final result = BankErrorMapper.map(error);

      expect(result.code, 'SERVER_ERROR');
    });

    test('maps connection error', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      final result = BankErrorMapper.map(error);

      expect(result.code, 'CONNECTION_ERROR');
    });

    test('maps timeout', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final result = BankErrorMapper.map(error);

      expect(result.code, 'TIMEOUT');
    });

    test('maps unknown error safely', () {
      final result = BankErrorMapper.map(Exception('internal error'));

      expect(result.code, 'UNKNOWN_ERROR');
      expect(result.message, 'Something went wrong. Please try again.');
    });
  });
}
