import 'package:fastnotes_flutter/core/exceptions/service_exception.dart';
import 'package:fastnotes_flutter/data/models/note_model.dart';
import 'package:fastnotes_flutter/data/services/note_service.dart';
import 'package:fastnotes_flutter/domain/entities/paginated_response_model.dart';
import 'package:fastnotes_flutter/core/exceptions/repository_exception.dart';
import 'package:fastnotes_flutter/domain/repositories/note_repository.dart';
import 'package:hive/hive.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteService _noteService;
  final Box _hive = Hive.box('auth');

  NoteRepositoryImpl({
    required NoteService noteService,
  }) : _noteService = noteService;

  @override
  Future<PaginatedResponseModel<NoteModel>?> getNotes(
    int page,
    int pageSize,
  ) async {
    try {
      final authModel = _hive.get('auth');
      if (authModel == null) {
        throw RepositoryException('User not logged in');
      }
      final userId = authModel[2];
      return await _noteService.getNotes(page, pageSize, userId);
    } on ServiceException catch (e) {
      throw RepositoryException(e.message, originalError: e);
    } catch (e) {
      throw RepositoryException(e.toString());
    }
  }

  @override
  Future<bool> deleteNote(int noteId) async {
    try {
      final authModel = _hive.get('auth');
      if (authModel == null) {
        throw RepositoryException('User not logged in');
      }
      final userId = authModel[2];
      return await _noteService.deleteNote(noteId, userId);
    } on ServiceException catch (e) {
      throw RepositoryException(e.message, originalError: e);
    } catch (e) {
      throw RepositoryException(e.toString());
    }
  }

  @override
  Future<bool> updateNote(
    int noteId,
    String title,
    String content,
  ) async {
    try {
      final authModel = _hive.get('auth');
      if (authModel == null) {
        throw RepositoryException('User not logged in');
      }
      final userId = authModel[2];
      return await _noteService.updateNote(noteId, userId, title, content);
    } on ServiceException catch (e) {
      throw RepositoryException(e.message, originalError: e);
    } catch (e) {
      throw RepositoryException(e.toString());
    }
  }

  @override
  Future<bool> createNote(String title, String content) async {
    try {
      final authModel = _hive.get('auth');
      if (authModel == null) {
        throw RepositoryException('User not logged in');
      }
      final userId = authModel[2];
      return await _noteService.createNote(userId, title, content);
    } on ServiceException catch (e) {
      throw RepositoryException(e.message, originalError: e);
    } catch (e) {
      throw RepositoryException(e.toString());
    }
  }
}
