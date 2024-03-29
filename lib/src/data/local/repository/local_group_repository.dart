import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'drift_group_repository.dart';
import 'package:langpocket/src/data/local/connection/connection.dart' as impl;

abstract class LocalGroupRepository {
  Stream<List<GroupData>> watchGroups();
  Future<GroupData> fetchGroupById(int groupId);
  Future<GroupData> fetchGroupByTime(DateTime now);
  Stream<GroupData> watchGroupById(int groupId);
  Future<GroupData> createGroup(GroupCompanion newgroup);
  Future<void> addNewWordInGroup(WordCompanion newWord);
  Future<WordData> fetchWordById(int groupId);
  Stream<List<WordData>> watchWordsByGroupId(int groupId);
  Future<List<WordData>> fetchWordsByGroupId(int groupId);
  Future<void> updateGroupName(int groupId, String newName);
  Future<void> deleteWordById(int wordId, int groupId);
  Future<List<WordData>> fetchAllWords();
  Stream<WordData> watchWordById(int wordId);
  Future<void> updateWordInf(int wordId, WordCompanion wordCompanion);
  Future<List<GroupData>> fetchAllGroups();
  Future<void> updateGroupLevel(int groupId, GroupCompanion newGroup);
  Future<void> markGroupAsSynced(int groupId);
  // Future<void> upsertGroups(List<Group> awsGroups);
  Future<({List<GroupData> groups, List<WordData> words})>
      fetchUnsyncedGroups();
}

// ignore: non_constant_identifier_names
final safe_acess_local_db = DriftGroupRepository(impl.connect());
final localGroupRepositoryProvider = Provider<LocalGroupRepository>((ref) {
  ref.onDispose(safe_acess_local_db.close);
  return safe_acess_local_db;
});
