import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pos/_core/common/pdf_service/statements_pdf.dart';
import 'package:pos/features/settings/controller/settings_ctrl.dart';
import 'package:pos/features/transactions/controller/transactions_ctrl.dart';
import 'package:pos/main.export.dart';

class TrxReportView extends HookConsumerWidget {
  const TrxReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trxCtrl = useCallback(() => ref.read(trxFilteredProvider.notifier));
    final range = useState<ShadDateTimeRange?>(null);
    final type = useState<TransactionType?>(null);

    return ShadDialog(
      title: const Text('Report'),
      actions: [
        ShadButton.destructive(onPressed: () => context.nPop(), child: const Text('Cancel')),
        SubmitButton(
          onPressed: (l) async {
            l.truthy();
            final config = await ref.read(configCtrlAsyncProvider.future);
            final trx = await trxCtrl().filter(range.value, type.value);

            final ctrl = PDFCtrl();
            final pdf = await StatementsPdf(trx, config, range.value?.start, range.value?.end).fullPDF();
            final doc = await ctrl.getDoc(pdf, PdfPageFormat.a4);
            final path = await ctrl.save(doc, 'statements_${DateTime.now().formatDate('yyyy-MM-dd_HH-mm')}');
            l.falsey();
            if (context.mounted) {
              Toast.show(
                context,
                'Statement download',
                action: (id) {
                  if (path == null) return null;
                  return ShadIconButton.ghost(
                    icon: const Icon(LuIcons.externalLink),
                    onPressed: () => OpenFilex.open(path),
                  );
                },
              );
            }
          },
          child: const Text('Download'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ShadDatePicker.range(onRangeChanged: range.set, selected: range.value),
              ),
              Expanded(
                child: ShadSelectField<TransactionType>(
                  hintText: 'All',
                  options: TransactionType.values,
                  selectedBuilder: (context, value) => Text(value.name.titleCase),
                  optionBuilder: (_, value, _) {
                    return ShadOption(value: value, child: Text(value.name.titleCase));
                  },
                  onChanged: (v) => type.set(v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
