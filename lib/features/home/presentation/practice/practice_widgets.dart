import 'package:flutter/material.dart';

import '../../../../core/theme/app_fonts.dart';
import 'practice_content.dart';
import 'practice_shell.dart';

/// Корзина: тап по товару или режим «выбрать → положить».
class PracticeBasket extends StatelessWidget {
  const PracticeBasket({
    super.key,
    required this.items,
    required this.selectedIds,
    required this.spent,
    required this.budget,
    required this.onToggle,
    this.altMode = false,
    this.pendingId,
    this.onPending,
    this.onDropZoneTap,
  });

  final List<PracticeGoods> items;
  final Set<String> selectedIds;
  final int spent;
  final int budget;
  final void Function(PracticeGoods item) onToggle;
  final bool altMode;
  final String? pendingId;
  final void Function(String id)? onPending;
  final VoidCallback? onDropZoneTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onDropZoneTap,
            child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1B6943), width: 2),
            ),
            child: Column(
              children: [
                Text(
                  'Корзина · $spent / $budget · остаток ${budget - spent}',
                  style: practiceHead,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  selectedIds.isEmpty
                      ? (altMode
                          ? 'Выбери товар, затем нажми сюда'
                          : 'Нажми на товар, чтобы положить')
                      : selectedIds
                          .map(
                            (id) => items
                                .firstWhere((e) => e.id == id)
                                .title,
                          )
                          .join(' · '),
                  textAlign: TextAlign.center,
                  style: practiceBody,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.35,
            children: [
              for (final item in items)
                _GoodsCard(
                  item: item,
                  selected: selectedIds.contains(item.id),
                  pending: pendingId == item.id,
                  onTap: () {
                    if (altMode) {
                      onPending?.call(item.id);
                    } else {
                      onToggle(item);
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoodsCard extends StatelessWidget {
  const _GoodsCard({
    required this.item,
    required this.selected,
    required this.onTap,
    this.pending = false,
  });

  final PracticeGoods item;
  final bool selected;
  final bool pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFDCEFE3) : const Color(0xFFFFF8E8),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: pending
                  ? const Color(0xFFDF9548)
                  : const Color(0xFF1B6943),
              width: selected || pending ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: item.imageAsset != null
                      ? Image.asset(item.imageAsset!, fit: BoxFit.contain)
                      : Icon(item.icon, color: const Color(0xFF1B6943), size: 36),
                ),
              ),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: const Color(0xFF1B6943),
                ),
              ),
              Text(
                '${item.price}${item.tag.isEmpty ? '' : ' · ${item.tag}'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: const Color(0xFF4A4643),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Распределение учебной суммы по корзинам.
class PracticeAllocateRow extends StatelessWidget {
  const PracticeAllocateRow({
    super.key,
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text('$label: $value', style: practiceBody)),
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove_circle_outline),
            color: const Color(0xFF1B6943),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add_circle_outline),
            color: const Color(0xFF1B6943),
          ),
        ],
      ),
    );
  }
}

/// Чек: отметить лишнюю строку + оплата монетами.
class PracticePayPad extends StatelessWidget {
  const PracticePayPad({
    super.key,
    required this.target,
    required this.paid,
    required this.onAdd,
    required this.onReset,
    this.altMode = false,
    this.pending,
    this.onPending,
  });

  final int target;
  final int paid;
  final void Function(int coin) onAdd;
  final VoidCallback onReset;
  final bool altMode;
  final int? pending;
  final void Function(int coin)? onPending;

  static const coins = [10, 10, 10, 10, 10, 5, 5, 1, 1, 1, 1, 1];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DragTarget<int>(
          onAcceptWithDetails: (d) => onAdd(d.data),
          builder: (context, cand, _) {
            return GestureDetector(
              onTap: () {
                if (altMode && pending != null) onAdd(pending!);
              },
              child: Container(
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cand.isNotEmpty
                      ? const Color(0xFFDCEFE3)
                      : const Color(0xFFFFF8E8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1B6943), width: 2),
                ),
                child: Text('Касса: $paid / $target', style: practiceHead),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (final v in coins)
                Draggable<int>(
                  data: v,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _coin(v, big: true),
                  ),
                  childWhenDragging: Opacity(opacity: 0.3, child: _coin(v)),
                  child: GestureDetector(
                    onTap: () {
                      if (altMode) {
                        onPending?.call(v);
                      } else {
                        onAdd(v);
                      }
                    },
                    child: _coin(v, selected: pending == v),
                  ),
                ),
            ],
          ),
        ),
        TextButton(onPressed: onReset, child: const Text('Исправить оплату')),
      ],
    );
  }

  Widget _coin(int v, {bool big = false, bool selected = false}) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFDF9548) : const Color(0xFFE8F5EC),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1B6943)),
      ),
      child: Text(
        '$v',
        style: AppFonts.rubik(
          fontWeight: FontWeight.w700,
          fontSize: big ? 18 : 14,
          color: const Color(0xFF1B6943),
        ),
      ),
    );
  }
}

class PracticeSelectTile extends StatelessWidget {
  const PracticeSelectTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? const Color(0xFFE8F5EC) : const Color(0xFFFEF7E6),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? const Color(0xFF1B6943)
                    : const Color(0xFF1B6943).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, softWrap: true, style: practiceHead),
                      Text(subtitle, softWrap: true, style: practiceBody),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: const Color(0xFF1B6943),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
