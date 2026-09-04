enum Entity { card, group, database }

enum DatabaseAction { create, read, update, delete, initialize }

enum DatabaseErrorType {
  connection,
  constraint,
  duplicate,
  notFound,
  unknown
}

class DatabaseOperationException implements Exception {
  final Entity entity;
  final DatabaseAction action;
  final DatabaseErrorType type;
  final Object? originalError;
  final Map<String, dynamic>? context;

  DatabaseOperationException({
    required this.entity,
    required this.action,
    this.type = DatabaseErrorType.unknown,
    this.originalError,
    this.context,
  });

  @override
  String toString() {
    var msg = 'Failed to $action $entity';
    
    if (type != DatabaseErrorType.unknown) {
      msg += ' ($type)';
    }
    
    if (context?.isNotEmpty ?? false) {
      final details = context!.entries
          .map((e) => '${e.key}=${e.value}')
          .join(', ');
      msg += ' [$details]';
    }
    
    msg += ': ${originalError ?? "unknown error"}';
    return msg;
  }
}