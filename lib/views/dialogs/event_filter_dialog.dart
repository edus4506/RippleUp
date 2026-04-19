import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewModels/event_viewModel.dart';

class EventFilterDialog extends StatefulWidget {
  const EventFilterDialog({super.key});

  @override
  State<EventFilterDialog> createState() => _EventFilterDialogState();
}

class _EventFilterDialogState extends State<EventFilterDialog> {
  late bool localValue;
  late Set<int> selectedGoals;

  @override
  void initState() {
    super.initState();
    final vm = context.read<EventViewModel>();
    localValue = vm.hideFullEvents;
    selectedGoals = Set.from(vm.selectedGoals);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filtros',
              style: theme.textTheme.titleMedium,
            ),

            const SizedBox(height: 20),

            CheckboxListTile(
              title: const Text('Esconder eventos cheios'),
              value: localValue,
              onChanged: (value) {
                setState(() {
                  localValue = value ?? false;
                });
              },
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Objetivos Ambientais',
                style: theme.textTheme.titleMedium,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 300,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 18,
                itemBuilder: (context, index) {
                  final goal = index + 1;

                  if (goal == 18) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }

                  final isSelected = selectedGoals.contains(goal);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedGoals.remove(goal);
                        } else {
                          selectedGoals.add(goal);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          goal.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        localValue = false;
                        selectedGoals.clear();
                      });
                    },
                    child: const Text('Limpar filtros'),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final vm = context.read<EventViewModel>();
                          vm.applyFilters(
                            hideFull: localValue,
                            goals: selectedGoals,
                          );

                          Navigator.pop(context);
                        },
                        child: const Text('Aplicar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}