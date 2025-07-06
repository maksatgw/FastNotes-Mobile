import 'package:fastnotes_flutter/data/models/note_model.dart';
import 'package:fastnotes_flutter/domain/entities/paginated_response_model.dart';

abstract class NoteRepository {
  Future<PaginatedResponseModel<NoteModel>?> getNotes(
    int page,
    int pageSize,
  );

  Future<bool> deleteNote(int noteId);

  Future<bool> updateNote(
    int noteId,
    String title,
    String content,
  );

  Future<bool> createNote(String title, String content);
}
