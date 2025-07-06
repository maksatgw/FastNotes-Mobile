import 'package:fastnotes_flutter/core/exceptions/repository_exception.dart';
import 'package:fastnotes_flutter/core/utils/snackbar_utils.dart';
import 'package:fastnotes_flutter/domain/repositories/note_repository.dart';
import 'package:fastnotes_flutter/presentation/service_locator.dart';
import 'package:flutter/material.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository _noteRepository = serviceLocator<NoteRepository>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> createNote(String title, String content) async {
    try {
      _resetError();
      changeLoadingState(true);
      final result = await _noteRepository.createNote(
        title,
        content,
      );
      if (result == true) {
        SnackbarUtils.showSuccessSnackbar('Not oluşturuldu');
      } else {
        SnackbarUtils.showErrorSnackbar('Not oluşturulamadı');
      }
    } on RepositoryException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Beklenmeyen bir hata oluştu');
    } finally {
      changeLoadingState(false);
      notifyListeners();
    }
  }

  Future<void> updateNote(int noteId, String title, String content) async {
    try {
      _resetError();
      changeLoadingState(true);
      final result = await _noteRepository.updateNote(
        noteId,
        title,
        content,
      );
      if (result == true) {
        SnackbarUtils.showSuccessSnackbar('Not güncellendi');
      } else {
        SnackbarUtils.showErrorSnackbar('Not güncellenemedi');
      }
    } on RepositoryException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Beklenmeyen bir hata oluştu');
    } finally {
      changeLoadingState(false);
      notifyListeners();
    }
  }

  Future<void> deleteNote(int noteId) async {
    try {
      _resetError();
      changeLoadingState(true);
      final result = await _noteRepository.deleteNote(
        noteId,
      );
      if (result == true) {
        SnackbarUtils.showSuccessSnackbar('Not silindi');
      } else {
        SnackbarUtils.showErrorSnackbar('Not silinemedi');
      }
    } on RepositoryException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Beklenmeyen bir hata oluştu');
    } finally {
      changeLoadingState(false);
      notifyListeners();
    }
  }

  void changeLoadingState(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _hasError = true;
  }

  void _resetError() {
    _errorMessage = null;
    _hasError = false;
  }
}
