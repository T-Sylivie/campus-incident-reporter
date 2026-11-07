import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';
import 'dart:io';
import '../services/storage_service.dart';

class IncidentProvider extends ChangeNotifier {
  /* final IncidentService _service; */
  final IncidentService _service;
  final StorageService _storage;
  StreamSubscription<List<Incident>>? _sub;
  AppUser? _user;
  String? _boundUid;
  bool _disposed = false;

  List<Incident> _all = [];
  bool _loading = false;
  bool _busy = false;
  String? _error;

  String _query = '';
  String? _statusFilter;
  String? _categoryFilter;

  /* IncidentProvider(this._service); */
  IncidentProvider(this._service, this._storage);


  // ---- Read-only state for the UI ----
  bool get loading => _loading;
  bool get busy => _busy;
  String? get error => _error;
  List<Incident> get all => _all;
  String get query => _query;
  String? get statusFilter => _statusFilter;
  String? get categoryFilter => _categoryFilter;

  List<Incident> get filtered {
    final q = _query.trim().toLowerCase();
    return _all.where((i) {
      if (_statusFilter != null && i.status != _statusFilter) return false;
      if (_categoryFilter != null && i.category != _categoryFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      return i.title.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q) ||
          i.location.toLowerCase().contains(q) ||
          i.category.toLowerCase().contains(q) ||
          i.refId.toLowerCase().contains(q);
    }).toList();
  }

  List<Incident> get mine =>
      _all.where((i) => i.reporterId == _boundUid).toList();

  int count(String status, {bool mineOnly = false}) {
    final list = mineOnly ? mine : _all;
    return list.where((i) => i.status == status).length;
  }

  Incident? byId(String id) {
    for (final i in _all) {
      if (i.id == id) return i;
    }
    return null;
  }

  // ---- Filters ----
  void setQuery(String v) {
    _query = v;
    notifyListeners();
  }

  void setStatusFilter(String? v) {
    _statusFilter = v;
    notifyListeners();
  }

  void setCategoryFilter(String? v) {
    _categoryFilter = v;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _statusFilter = null;
    _categoryFilter = null;
    notifyListeners();
  }

  // ---- Connect to the signed-in user (called from the provider setup) ----
  void bind(AppUser? user) {
    _user = user;
    if (user?.uid == _boundUid) return;

    _sub?.cancel();
    _sub = null;
    _boundUid = user?.uid;
    _all = [];
    _error = null;
    _loading = user != null;

    if (user != null) {
      _sub = _service.watchAll().listen(
        (list) {
          _all = list;
          _loading = false;
          _error = null;
          _notify();
        },
        onError: (_) {
          _loading = false;
          _error = 'Could not load reports. Check your connection.';
          _notify();
        },
      );
    }
    // Avoid notifying while the widget tree is building.
    scheduleMicrotask(_notify);
  }

  // ---- Actions ----
/*   Future<bool> submit({
    required String title,
    required String description,
    required String category,
    required String location,
    required String urgency,
    required bool isAnonymous,
    String? imageUrl,
  }) {
    final user = _user;
    if (user == null) return Future.value(false);
    return _run(() => _service.create(
          reporter: user,
          title: title,
          description: description,
          category: category,
          location: location,
          urgency: urgency,
          isAnonymous: isAnonymous,
          imageUrl: imageUrl,
        ));
  } */
      Future<bool> submit({
    required String title,
    required String description,
    required String category,
    required String location,
    required String urgency,
    required bool isAnonymous,
    File? image,
  }) {
    final user = _user;
    if (user == null) return Future.value(false);
    return _run(() async {
      String? imageUrl;
      if (image != null) {
        imageUrl = await _storage.uploadImage(image);
      }
      await _service.create(
        reporter: user,
        title: title,
        description: description,
        category: category,
        location: location,
        urgency: urgency,
        isAnonymous: isAnonymous,
        imageUrl: imageUrl,
      );
    });
  }



  Future<bool> updateStatus(String id, String status, String note) {
    final user = _user;
    if (user == null || !user.isStaff) return Future.value(false);
    return _run(() => _service.updateStatus(
          id: id,
          status: status,
          note: note,
          staff: user,
        ));
  }

  Future<bool> delete(String id) => _run(() => _service.delete(id));

  Future<bool> _run(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (_) {
      _error = 'Action failed. Please try again.';
      return false;
    } finally {
      _busy = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    super.dispose();
  }
}