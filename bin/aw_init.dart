import 'dart:convert';
import 'dart:io';

import 'package:pos/_core/database/aw_const.dart';

final _dbId = AWConst.databaseId.id;
final _userCollId = AWConst.collections.users.id;
final _roleCollId = AWConst.collections.role.id;
final _configCollId = AWConst.collections.config.id;
final _configDocId = AWConst.docs.config.id;
final _whCollId = AWConst.collections.warehouse.id;
const _whDocId = '68240e5547c2c832c574';
const _adminRoleId = '680a082b001d1b08d793';
const _adminId = '6817c1c0002570812122';
const _email = 'admin@gmail.com';
const _pass = '12341234';

const _user = {
  'name': 'Admin',
  'phone': '',
  'email': _email,
  'role': _adminRoleId,
  'is_user_created': true,
  'warehouse': _whDocId,
};
const _config = {'currency_symbol': '\$'};
const _wh = {'name': 'HQ', 'address': '--', 'is_default': true, 'contact_number': '--'};

final _role = {
  'name': 'admin',
  'enabled': true,
  'permissions': [
    'manageProduct',
    'manageStock',
    'manageUnit',
    'makeSale',
    'returnSale',
    'makePurchase',
    'returnPurchase',
    'manageCustomer',
    'manageSupplier',
    'manageStaff',
    'manageRole',
    'manageWarehouse',
    'transferStock',
    'manageAccounts',
    'manageExpanse',
    'moneyTransfer',
    'transferMoney',
    'transactions',
    'due',
  ],
};

void main(List<String> args) async {
  final arg = args.firstOrNull;

  if (arg == null) return stdout.writeln('Pass an arg');

  if (arg == 'adminAcc') {
    _account();
  }

  if (arg == 'adminDoc') {
    await createDoc(coll: _whCollId, docId: _whDocId, data: _wh);
    await createDoc(coll: _roleCollId, docId: _adminRoleId, data: _role);
    await createDoc(coll: _userCollId, docId: _adminId, data: _user);
  }

  if (arg == 'config') {
    await createDoc(coll: _configCollId, docId: _configDocId, data: _config);
  }
}

Future createDoc({required String coll, required String docId, required Map data}) async {
  final doc = await Process.run('appwrite', [
    'databases',
    'create-document',
    '--database-id',
    _dbId,
    '--collection-id',
    coll,
    '--document-id',
    docId,
    '--data',
    jsonEncode(data),
    '--verbose',
  ], runInShell: true);

  stdout.writeln(doc.stdout);
  stdout.writeln(doc.stderr);
}

void _account() {
  final acc = Process.runSync('appwrite', [
    'users',
    'create',
    '--user-id',
    _adminId,
    '--email',
    _email,
    '--password',
    _pass,
    '--name',
    'Admin',
  ], runInShell: true);

  stdout.writeln(acc.stdout);
  stdout.writeln(acc.stderr);
}
