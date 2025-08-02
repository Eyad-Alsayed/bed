import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/booking.dart';
import '../models/comment.dart';
import 'logger_service.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDB('bookings.db');
      LoggerService.info('Database initialized successfully');
      return _database!;
    } catch (e, stackTrace) {
      LoggerService.error('Database initialization error', e, stackTrace);
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bookings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientMrn TEXT NOT NULL,
        procedure TEXT NOT NULL,
        urgency TEXT NOT NULL,
        consultantName TEXT NOT NULL,
        consultantPhone TEXT NOT NULL,
        physicianName TEXT NOT NULL,
        physicianPhone TEXT NOT NULL,
        anesthesiaManagerName TEXT NOT NULL,
        anesthesiaManagerPhone TEXT NOT NULL,
        anesthesiaConsultantName TEXT NOT NULL,
        anesthesiaConsultantPhone TEXT NOT NULL,
        bookingTime TEXT NOT NULL,
        bookingStatus TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE comments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookingId INTEGER NOT NULL,
        commenterName TEXT NOT NULL,
        commentText TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (bookingId) REFERENCES bookings (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> createBooking(Booking booking) async {
    final db = await instance.database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<List<Booking>> getAllBookings() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('bookings');
    return List.generate(maps.length, (i) => Booking.fromMap(maps[i]));
  }

  Future<int> updateBooking(Booking booking) async {
    final db = await instance.database;
    return await db.update(
      'bookings',
      booking.toMap(),
      where: 'id = ?',
      whereArgs: [booking.id],
    );
  }

  Future<int> deleteBooking(int id) async {
    final db = await instance.database;
    return await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> createComment(Comment comment) async {
    final db = await instance.database;
    return await db.insert('comments', comment.toMap());
  }

  Future<List<Comment>> getCommentsForBooking(int bookingId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'comments',
      where: 'bookingId = ?',
      whereArgs: [bookingId],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) => Comment.fromMap(maps[i]));
  }

  Future<Booking?> getBookingById(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Booking.fromMap(maps.first);
  }
}
