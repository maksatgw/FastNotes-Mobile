import 'package:fastnotes_flutter/core/exceptions/repository_exception.dart';
import 'package:fastnotes_flutter/core/utils/snackbar_utils.dart';
import 'package:fastnotes_flutter/data/models/note_model.dart';
import 'package:fastnotes_flutter/domain/repositories/auth_repository.dart';
import 'package:fastnotes_flutter/domain/repositories/note_repository.dart';
import 'package:fastnotes_flutter/presentation/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class HomeProvider extends ChangeNotifier {
  // Repository
  final NoteRepository _noteRepository = serviceLocator<NoteRepository>();
  final Box<dynamic> _hiveUser = Hive.box('user');
  // State
  final List<NoteModel> _notes = [];
  List<NoteModel> get notes => _notes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  bool _hasNext = false;
  bool get hasNext => _hasNext;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  GoogleSignInAccount? _loggedInUser;
  GoogleSignInAccount? get loggedInUser => _loggedInUser;

  String? _loggedInUserDisplayName;
  String? get loggedInUserDisplayName => _loggedInUserDisplayName;

  String? _loggedInUserEmail;
  String? get loggedInUserEmail => _loggedInUserEmail;

  String? _loggedInUserPhotoUrl;
  String? get loggedInUserPhotoUrl => _loggedInUserPhotoUrl;

  // Get Notes Initial
  Future<void> getNotesInit() async {
    try {
      _resetError();
      _currentPage = 1;
      changeLoadingState(true);

      // Get the first page
      final notes = await _noteRepository.getNotes(
        1,
        10,
      );
      if (notes != null) {
        _notes.clear();
        _notes.addAll(notes.items);
        _hasNext = notes.hasNext;
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

  // Get Notes More
  Future<void> getNotesMore() async {
    try {
      _resetError();
      changeLoadingMoreState(true);

      // Get the next page
      final notes = await _noteRepository.getNotes(
        _currentPage,
        10,
      );

      if (notes != null) {
        _notes.addAll(notes.items);
        _hasNext = notes.hasNext;
      }
    } on RepositoryException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Beklenmeyen bir hata oluştu');
    } finally {
      changeLoadingMoreState(false);
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
        await getNotesInit();
        SnackbarUtils.showSuccessSnackbar('Not silindi');
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

  // Get Logged In User
  Future<void> getLoggedInUser() async {
    try {
      _resetError();

      // Hive'dan kullanıcı bilgilerini al
      final userData = _hiveUser.get('user');

      if (userData != null && userData is List && userData.length >= 3) {
        _loggedInUserDisplayName = userData[0];
        _loggedInUserEmail = userData[1];
        _loggedInUserPhotoUrl = userData[2];
      } else {
        // Eğer kullanıcı bilgileri Hive'da yoksa, repository'den almayı dene
        final authRepository = serviceLocator<AuthRepository>();
        await authRepository.getLoggedInUser();

        // Tekrar Hive'dan almayı dene
        final updatedUserData = _hiveUser.get('user');
        if (updatedUserData != null &&
            updatedUserData is List &&
            updatedUserData.length >= 3) {
          _loggedInUserDisplayName = updatedUserData[0];
          _loggedInUserEmail = updatedUserData[1];
          _loggedInUserPhotoUrl = updatedUserData[2];
        } else {
          _setError('Kullanıcı bilgileri alınamadı');
        }
      }
    } catch (e) {
      _setError('Kullanıcı bilgileri alınamadı: ${e.toString()}');
    } finally {
      notifyListeners();
    }
  }

  // Change Current Page
  void changeCurrentPage() {
    if (_hasNext == true) {
      _currentPage++;
      getNotesMore();
    }
  }

  // Change Loading State
  void changeLoadingState(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Change Loading More State
  void changeLoadingMoreState(bool value) {
    _isLoadingMore = value;
    notifyListeners();
  }

  // Hata durumunu ayarla
  void _setError(String message) {
    _errorMessage = message;
    _hasError = true;
  }

  // Hata durumunu sıfırla
  void _resetError() {
    _errorMessage = null;
    _hasError = false;
  }
}
