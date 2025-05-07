import 'package:appwrite/models.dart';
import 'package:pos/main.export.dart';

class PaymentAccountsRepo with AwHandler {
  FutureReport<Document> createAccount(QMap form) async {
    final acc = PaymentAccount.fromMap(form);
    final doc = await db.create(AWConst.collections.paymentAccount, data: acc.toAwPost());
    return doc;
  }

  FutureReport<Document> updateAccount(PaymentAccount acc) async {
    final doc = await db.update(AWConst.collections.paymentAccount, acc.id, data: acc.toAwPost());
    return doc;
  }

  FutureReport<List<PaymentAccount>> getAccount() async {
    return await db
        .getList(AWConst.collections.paymentAccount)
        .convert((docs) => docs.convertDoc(PaymentAccount.fromDoc));
  }

  FutureReport<PaymentAccount> getAccountById(String id) async {
    return await db.get(AWConst.collections.paymentAccount, id).convert(PaymentAccount.fromDoc);
  }
}
