import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:project_ai_chat/models/knowledge.dart';
import 'package:project_ai_chat/services/knowledgebase_service.dart';

class KnowledgeBaseViewModel with ChangeNotifier {
  final KnowledgebaseService _kbService = KnowledgebaseService();
  final List<Knowledge> _knowledgeBases = [];
  bool isLoading = false;
  String? error;

  // loadmore kb
  int? _offset = 0;
  int? _limit = 10;
  bool _hasNext = true;
  String _query = '';
  // load more kb
  bool get hasNext => _hasNext;

  // loadmore unit
  int? _offsetUnit = 0;
  int? _limitUnit = 10;
  bool _hasNextUnit = true;
  String _queryUnit = '';
  // load more kb
  bool get hasNextUnit => _hasNextUnit;

  Future<void> query(String value) async {
    if (_query != value) {
      _query = value;
      fetchAllKnowledgeBases(isLoadMore: false);
      notifyListeners();
    }
  }

  Future<void> queryUnit(String value, String knowledgeId) async {
    if (_queryUnit != value) {
      _queryUnit = value;
      fetchUnitsOfKnowledge(false, knowledgeId);
      notifyListeners();
    }
  }

  Knowledge getKnowledgeById(String id) {
    try {
      return _knowledgeBases.firstWhere((kb) => kb.id == id);
    } catch (e) {
      return Knowledge(
          name: 'name',
          description: 'description',
          imageUrl: 'imageUrl',
          id: 'id');
    }
  }

  List<Knowledge> get knowledgeBases => _knowledgeBases;

  Future<void> fetchAllKnowledgeBases({bool isLoadMore = false}) async {
    if (isLoadMore && _hasNext == false) {
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    if (isLoadMore == false) {
      _offset = 0;
      _hasNext = true;
    }

    final response =
        await _kbService.getAllKnowledgeBases(_offset, _limit, _query);

    if (response.success && response.data != null) {
      if (isLoadMore == false) {
        _knowledgeBases.clear();
      }
      _knowledgeBases.addAll(
        (response.data['data'] as List<dynamic>)
            .map((item) => Knowledge.fromJson(item)),
      );
      _offset = response.data['meta']["offset"] + _limit;
      _hasNext = response.data['meta']["hasNext"];
      isLoading = false;
      notifyListeners();
    } else {
      isLoading = false;
      error = response.message;
      notifyListeners();
      // logout();
      // throw response;
    }
  }

  Future<bool> addKnowledgeBase(
      String knowledgeName, String description) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response =
          await _kbService.createKnowledge(knowledgeName, description);

      if (response.success) {
        Knowledge newKnowledge = Knowledge(
          id: response.data['id'],
          name: response.data['knowledgeName'],
          description: response.data['description'],
          imageUrl: "assets/images/open-book.png",
        );
        _knowledgeBases.add(newKnowledge);
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = response.message;
        return false;
      }
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editKnowledgeBase(
      String id, int index, String knowledgeName, String description) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response =
          await _kbService.editKnowledge(id, knowledgeName, description);

      if (response.success) {
        // update knowledge base in the list
        _knowledgeBases[index] = Knowledge(
          id: id,
          name: knowledgeName,
          description: description,
          imageUrl: "assets/images/open-book.png",
        );

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = response.message;
        return false;
      }
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteKnowledgeBase(String id, int index) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _kbService.deleteKnowledge(id);

      if (response.success) {
        // delete knowledge base in the list
        _knowledgeBases.removeAt(index);

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = response.message;
        return false;
      }
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadLocalFiles(List<File> selectedFiles, String knowledgeId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response =
      await _kbService.uploadLocalFiles(selectedFiles, knowledgeId);

      if (response.success) {
        final knowledgeIndex =
        _knowledgeBases.indexWhere((kb) => kb.id == knowledgeId);

        if (knowledgeIndex != -1) {
          final datasources = response.data['datasources'] as List<dynamic>;
          for (var data in datasources) {
            _knowledgeBases[knowledgeIndex].listUnits.add(
              Unit(
                unitName: data['name'],
                unitId: data['id'],
                unitType: data['type'],
                isActived: true,
              ),
            );
          }
        }
        return true;
      } else {
        error = response.message;
        return false;
      }
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnitsOfKnowledge(bool isLoadMore, String knowledgeId) async {
    if (isLoadMore && _hasNextUnit == false) {
      return;
    }
    isLoading = true;
    error = null;
    notifyListeners();

    if (isLoadMore == false) {
      _offsetUnit = 0;
      _hasNextUnit = true;
    }

    final response = await _kbService.getUnitsOfKnowledge(
        knowledgeId, _offsetUnit, _limitUnit, _queryUnit);

    if (response.success && response.data != null) {
      final knowledgeIndex =
          _knowledgeBases.indexWhere((kb) => kb.id == knowledgeId);

      if (isLoadMore == false) {
        _knowledgeBases[knowledgeIndex].listUnits = [];
      }

      List<Unit> units = [];
      units.addAll(_knowledgeBases[knowledgeIndex].listUnits);

      units.addAll(
        (response.data['data'] as List<dynamic>)
            .map((item) => Unit.fromJson(item)),
      );

      _knowledgeBases[knowledgeIndex] = Knowledge(
        name: _knowledgeBases[knowledgeIndex].name,
        description: _knowledgeBases[knowledgeIndex].description,
        imageUrl: _knowledgeBases[knowledgeIndex].imageUrl,
        id: _knowledgeBases[knowledgeIndex].id,
        listUnits: units,
      );
      _offsetUnit = response.data['meta']["offset"] + _limitUnit;
      _hasNextUnit = response.data['meta']["hasNext"];
      isLoading = false;
      notifyListeners();
    } else {
      isLoading = false;
      error = response.message;
      notifyListeners();
      // logout();
      // throw response;
    }
  }

  Future<bool> deleteUnit(String unitId, String knowledgeId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _kbService.deleteUnit(unitId, knowledgeId);
      print("Is success ${response.success}");

      if (response.success) {
        final knowledgeIndex =
            _knowledgeBases.indexWhere((kb) => kb.id == knowledgeId);

        if (knowledgeIndex != -1) {
          final unitIndex = _knowledgeBases[knowledgeIndex]
              .listUnits
              .indexWhere((unit) => unit.unitId == unitId);

          if (unitIndex != -1) {
            _knowledgeBases[knowledgeIndex].listUnits.removeAt(unitIndex);
          }
        }
        return true;
      } else {
        error = response.message ?? 'Delete unit failed';
        return false;
      }
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatusUnit(
      String knowledgeId, String unitId, bool isActived) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _kbService.updateStatusUnit(knowledgeId, unitId, isActived);

      if (response.success) {
        final knowledgeIndex =
            _knowledgeBases.indexWhere((kb) => kb.id == knowledgeId);

        if (knowledgeIndex != -1) {
          final unitIndex = _knowledgeBases[knowledgeIndex]
              .listUnits
              .indexWhere((unit) => unit.unitId == unitId);

          if (unitIndex != -1) {
            _knowledgeBases[knowledgeIndex].listUnits[unitIndex].isActived =
                isActived;
          }
        }
        return true;
      } else {
        error = response.message;
        return false;
      }
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadWebUrl(
      String knowledgeId, String webName, String webUrl) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response =
          await _kbService.uploadWebUrl(knowledgeId, webName, webUrl);

      if (response.success) {
        final knowledgeIndex =
            _knowledgeBases.indexWhere((kb) => kb.id == knowledgeId);

        if (knowledgeIndex != -1) {
          final data = response.data['datasources'][0];
          _knowledgeBases[knowledgeIndex].listUnits.add(
            Unit(
              unitName: data['name'],
              unitId: data['id'],
              unitType: data['type'],
              isActived: true,
            ),
          );
        }
        return true;
      } else {
        error = response.message;
        return false;
      }
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadSlack(String knowledgeId, String slackName, String slackBotToken) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _kbService.uploadSlack(
          knowledgeId, slackName, slackBotToken);

      if (response.success) {
        final knowledgeIndex =
            _knowledgeBases.indexWhere((kb) => kb.id == knowledgeId);

        if (knowledgeIndex != -1) {
          final data = response.data['datasources'][0];
          _knowledgeBases[knowledgeIndex].listUnits.add(
            Unit(
              unitName: data['name'],
              unitId: data['id'],
              unitType: data['type'],
              isActived: true,
            ),
          );
        }
        return true;
      } else {
        error = response.message;
        return false;
      }
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadConfluence(String knowledgeId, String confluenceName, String wikiPageUrl, String confluenceEmail, String confluenceToken) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _kbService.uploadConfluence(
          knowledgeId, confluenceName, wikiPageUrl, confluenceEmail, confluenceToken);

      if (response.success) {
        final knowledgeIndex =
            _knowledgeBases.indexWhere((kb) => kb.id == knowledgeId);

        if (knowledgeIndex != -1) {
          final data = response.data['datasources'][0];
          _knowledgeBases[knowledgeIndex].listUnits.add(
            Unit(
              unitName: data['name'],
              unitId: data['id'],
              unitType: data['type'],
              isActived: true,
            ),
          );
        }
        return true;
      } else {
        error = response.message;
        return false;
      }
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
