import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/splitTransactionHelper.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Modal interactivo para dividir el monto total de una transacción en múltiples categorías.
class SplitTransactionModal extends StatefulWidget {
  final double totalAmount;
  final List<TransactionCategorySplit> initialSplits;
  final Function(List<TransactionCategorySplit>) onSave;

  const SplitTransactionModal({
    Key? key,
    required this.totalAmount,
    required this.initialSplits,
    required this.onSave,
  }) : super(key: key);

  @override
  State<SplitTransactionModal> createState() => _SplitTransactionModalState();
}

class _SplitTransactionModalState extends State<SplitTransactionModal> {
  late List<TransactionCategorySplit> splits;

  @override
  void initState() {
    super.initState();
    splits = List.from(widget.initialSplits);
    if (splits.isEmpty && widget.totalAmount > 0) {
      splits.add(TransactionCategorySplit(
        categoryFk: "0",
        amount: widget.totalAmount,
      ));
    }
  }

  double get allocatedTotal =>
      splits.fold(0.0, (sum, item) => sum + item.amount);
  double get remainingAmount => widget.totalAmount - allocatedTotal;

  @override
  Widget build(BuildContext context) {
    final allWallets = Provider.of<AllWallets>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final validation =
        SplitTransactionHelper.validateSplitSum(widget.totalAmount, splits);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextFont(
                text: "Dividir Transacción",
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextFont(
                text: "Total: ${convertToMoney(allWallets, widget.totalAmount)}",
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              TextFont(
                text: "Restante: ${convertToMoney(allWallets, remainingAmount)}",
                fontSize: 14,
                textColor: validation.isValid ? Colors.green : Colors.orangeAccent,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const Divider(height: 24),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: splits.length,
              itemBuilder: (context, index) {
                final split = splits[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: OutlinedButton(
                          onPressed: () async {
                            openBottomSheet(
                              context,
                              SelectCategory(
                                setSelectedCategory: (cat) {
                                  setState(() {
                                    split.categoryFk = cat.categoryPk;
                                  });
                                },
                              ),
                            );
                          },
                          child: TextFont(
                            text: "Categoría #${index + 1}",
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: split.amount.toStringAsFixed(2),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            setState(() {
                              split.amount = double.tryParse(val) ?? 0.0;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            splits.removeAt(index);
                          });
                        },
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const TextFont(text: "Agregar división"),
                onPressed: () {
                  setState(() {
                    splits.add(TransactionCategorySplit(
                      categoryFk: "0",
                      amount: remainingAmount > 0 ? remainingAmount : 0.0,
                    ));
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Button(
            label: "Guardar Divisiones",
            onTap: () {
              widget.onSave(splits);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
