// Mocks generated by Mockito 5.4.6 from annotations
// in talk_pilot/test/services/project/estimated_time_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;

import 'package:firebase_auth/firebase_auth.dart' as _i11;
import 'package:firebase_database/firebase_database.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i6;
import 'package:talk_pilot/src/models/project_model.dart' as _i4;
import 'package:talk_pilot/src/models/user_model.dart' as _i10;
import 'package:talk_pilot/src/services/database/database_stream_service.dart'
    as _i2;
import 'package:talk_pilot/src/services/database/project_service.dart' as _i8;
import 'package:talk_pilot/src/services/database/project_stream_service.dart'
    as _i5;
import 'package:talk_pilot/src/services/database/user_service.dart' as _i9;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeDatabaseStreamService_0 extends _i1.SmartFake
    implements _i2.DatabaseStreamService {
  _FakeDatabaseStreamService_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeFirebaseDatabase_1 extends _i1.SmartFake
    implements _i3.FirebaseDatabase {
  _FakeFirebaseDatabase_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeProjectModel_2 extends _i1.SmartFake implements _i4.ProjectModel {
  _FakeProjectModel_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [ProjectStreamService].
///
/// See the documentation for Mockito's code generation for more information.
class MockProjectStreamService extends _i1.Mock
    implements _i5.ProjectStreamService {
  MockProjectStreamService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.DatabaseStreamService get streamHelper =>
      (super.noSuchMethod(
            Invocation.getter(#streamHelper),
            returnValue: _FakeDatabaseStreamService_0(
              this,
              Invocation.getter(#streamHelper),
            ),
          )
          as _i2.DatabaseStreamService);

  @override
  _i3.FirebaseDatabase get firebaseDatabase =>
      (super.noSuchMethod(
            Invocation.getter(#firebaseDatabase),
            returnValue: _FakeFirebaseDatabase_1(
              this,
              Invocation.getter(#firebaseDatabase),
            ),
          )
          as _i3.FirebaseDatabase);

  @override
  String get basePath =>
      (super.noSuchMethod(
            Invocation.getter(#basePath),
            returnValue: _i6.dummyValue<String>(
              this,
              Invocation.getter(#basePath),
            ),
          )
          as String);

  @override
  _i7.Stream<_i4.ProjectModel> streamProject(String? projectId) =>
      (super.noSuchMethod(
            Invocation.method(#streamProject, [projectId]),
            returnValue: _i7.Stream<_i4.ProjectModel>.empty(),
          )
          as _i7.Stream<_i4.ProjectModel>);

  @override
  _i7.Stream<List<_i4.ProjectModel>> streamUserProjects(String? uid) =>
      (super.noSuchMethod(
            Invocation.method(#streamUserProjects, [uid]),
            returnValue: _i7.Stream<List<_i4.ProjectModel>>.empty(),
          )
          as _i7.Stream<List<_i4.ProjectModel>>);
}

/// A class which mocks [ProjectService].
///
/// See the documentation for Mockito's code generation for more information.
class MockProjectService extends _i1.Mock implements _i8.ProjectService {
  MockProjectService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get basePath =>
      (super.noSuchMethod(
            Invocation.getter(#basePath),
            returnValue: _i6.dummyValue<String>(
              this,
              Invocation.getter(#basePath),
            ),
          )
          as String);

  @override
  _i7.Future<_i4.ProjectModel> writeProject({
    required String? title,
    required String? description,
    required String? ownerUid,
    required Map<String, String>? participants,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#writeProject, [], {
              #title: title,
              #description: description,
              #ownerUid: ownerUid,
              #participants: participants,
            }),
            returnValue: _i7.Future<_i4.ProjectModel>.value(
              _FakeProjectModel_2(
                this,
                Invocation.method(#writeProject, [], {
                  #title: title,
                  #description: description,
                  #ownerUid: ownerUid,
                  #participants: participants,
                }),
              ),
            ),
          )
          as _i7.Future<_i4.ProjectModel>);

  @override
  _i7.Future<_i4.ProjectModel?> readProject(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#readProject, [id]),
            returnValue: _i7.Future<_i4.ProjectModel?>.value(),
          )
          as _i7.Future<_i4.ProjectModel?>);

  @override
  _i7.Future<void> updateProject(String? id, Map<String, dynamic>? updates) =>
      (super.noSuchMethod(
            Invocation.method(#updateProject, [id, updates]),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<void> deleteProject(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#deleteProject, [id]),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<List<_i4.ProjectModel>> fetchProjects(String? uid) =>
      (super.noSuchMethod(
            Invocation.method(#fetchProjects, [uid]),
            returnValue: _i7.Future<List<_i4.ProjectModel>>.value(
              <_i4.ProjectModel>[],
            ),
          )
          as _i7.Future<List<_i4.ProjectModel>>);

  @override
  _i7.Future<void> initProject(_i4.ProjectModel? project) =>
      (super.noSuchMethod(
            Invocation.method(#initProject, [project]),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);
}

/// A class which mocks [UserService].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserService extends _i1.Mock implements _i9.UserService {
  MockUserService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<void> writeUser(
    _i10.UserModel? user, {
    bool? onlyIfAbsent = false,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #writeUser,
              [user],
              {#onlyIfAbsent: onlyIfAbsent},
            ),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<_i10.UserModel?> readUser(String? uid) =>
      (super.noSuchMethod(
            Invocation.method(#readUser, [uid]),
            returnValue: _i7.Future<_i10.UserModel?>.value(),
          )
          as _i7.Future<_i10.UserModel?>);

  @override
  _i7.Future<void> updateUser(String? uid, Map<String, dynamic>? updates) =>
      (super.noSuchMethod(
            Invocation.method(#updateUser, [uid, updates]),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<void> deleteUser(String? uid) =>
      (super.noSuchMethod(
            Invocation.method(#deleteUser, [uid]),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);

  @override
  _i7.Future<void> initUser(_i11.User? firebaseUser, {String? loginMethod}) =>
      (super.noSuchMethod(
            Invocation.method(
              #initUser,
              [firebaseUser],
              {#loginMethod: loginMethod},
            ),
            returnValue: _i7.Future<void>.value(),
            returnValueForMissingStub: _i7.Future<void>.value(),
          )
          as _i7.Future<void>);
}
