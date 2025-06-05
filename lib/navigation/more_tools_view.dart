import 'package:pos/features/auth/controller/auth_ctrl.dart';
import 'package:pos/main.export.dart';
import 'package:pos/navigation/nav_root.dart';

class MoreToolsView extends ConsumerWidget {
  const MoreToolsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(authStateSyncProvider).toNullable()?.role?.permissions ?? [];
    final items = navItems(permissions).map((e) => e.$2 == null ? null : (e.$1, e.$2!, e.$3!)).nonNulls.toList();

    return BaseBody(
      title: 'More Tools',
      scrollable: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = width < 600
              ? 2
              : width < 900
              ? 3
              : width < 1200
              ? 4
              : 5;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 140,
            ),
            itemBuilder: (context, index) => _ToolCard(item: items[index]),
          );
        },
      ),
    );
  }
}

class _ToolCard extends HookWidget {
  const _ToolCard({required this.item});

  final (String, IconData, RPath) item;

  @override
  Widget build(BuildContext context) {
    final (label, icon, path) = item;
    final isHovering = useState(false);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return GestureDetector(
      onTap: () => path.pushNamed(context),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => isHovering.value = true,
        onExit: (_) => isHovering.value = false,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: isHovering.value && !isMobile ? 1.03 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.border),
              boxShadow: isHovering.value && !isMobile
                  ? [
                      BoxShadow(
                        color: Colors.black.op(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.primary.op(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: context.colors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: context.text.p.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
