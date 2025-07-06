import 'package:fastnotes_flutter/core/exceptions/service_exception.dart';
import 'package:fastnotes_flutter/core/network/dio_client.dart';
import 'package:fastnotes_flutter/data/models/note_model.dart';
import 'package:dio/dio.dart';
import 'package:fastnotes_flutter/app/config/app_constants.dart';
import 'package:fastnotes_flutter/domain/entities/paginated_response_model.dart';
import 'dart:io';

abstract class NoteService {
  Future<PaginatedResponseModel<NoteModel>?> getNotes(
    int page,
    int pageSize,
    String userId,
  );

  Future<bool> deleteNote(int noteId, String userId);

  Future<bool> updateNote(
    int noteId,
    String userId,
    String title,
    String content,
  );

  Future<bool> createNote(String userId, String title, String content);
}

class NoteServiceImpl implements NoteService {
  final Dio _dio;

  NoteServiceImpl() : _dio = DioClient.instance;

  @override
  Future<PaginatedResponseModel<NoteModel>?> getNotes(
    int page,
    int pageSize,
    String userId,
  ) async {
    try {
      final response = await _dio.get(
        AppConstants.notesPath,
        queryParameters: {
          'pageNumber': page,
          'pageSize': pageSize,
          'userId': userId,
        },
      );
      // API yanıtının yapısını kontrol et
      final paginatedResponse = PaginatedResponseModel<NoteModel>.fromJson(
        response.data,
        (json) => NoteModel.fromJson(json),
      );
      return paginatedResponse;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ServiceException('Connection timeout', statusCode: 408);
      }
      throw ServiceException(
        e.response?.data['message'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServiceException(e.toString(), statusCode: 500);
    }
  }

  @override
  Future<bool> deleteNote(int noteId, String userId) async {
    try {
      final response = await _dio.delete(
        AppConstants.notesPath,
        data: {
          'id': noteId,
          'userId': userId,
        },
      );
      if (response.statusCode == HttpStatus.noContent) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ServiceException('Connection timeout', statusCode: 408);
      }
      print(e.response?.data);
      throw ServiceException(
        e.response?.data['message'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServiceException(e.toString(), statusCode: 500);
    }
  }

  @override
  Future<bool> updateNote(
    int noteId,
    String userId,
    String title,
    String content,
  ) async {
    try {
      final response = await _dio.put(
        AppConstants.notesPath,
        data: {
          'id': noteId,
          'userId': userId,
          'title': title,
          'content': content,
        },
      );
      if (response.statusCode == HttpStatus.ok) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ServiceException('Connection timeout', statusCode: 408);
      }
      throw ServiceException(
        e.response?.data['message'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServiceException(e.toString(), statusCode: 500);
    }
  }

  @override
  Future<bool> createNote(String userId, String title, String content) async {
    try {
      final response = await _dio.post(
        AppConstants.notesPath,
        data: {
          'userId': userId,
          'title': title,
          'content': content,
        },
      );
      if (response.statusCode == HttpStatus.created) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ServiceException('Connection timeout', statusCode: 408);
      }
      throw ServiceException(
        e.response?.data['message'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServiceException(e.toString(), statusCode: 500);
    }
  }
}
