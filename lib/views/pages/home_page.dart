import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewModels/event_viewModel.dart';
import '../widgets/bottom_nav.dart'; // Garante que o caminho está correto
import 'profile_page.dart';
import 'events_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Conteúdo de cada aba
  final List<Widget> _pages = [
    const EventsPage(),
    const Center(child: Text('Tarefas', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Favoritos', style: TextStyle(fontSize: 24))),
    const ProfilePage(),
  ];

  void _openFilterModal() {
    showDialog(
      context: context,
      builder: (context) {
        bool localValue = context.read<EventViewModel>().hideFullEvents;
        Set<int> selectedGoals =
            Set.from(context.read<EventViewModel>().selectedGoals);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Filtros',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: const Text('Esconder eventos cheios'),
                      value: localValue,
                      onChanged: (value) {
                        setModalState(() {
                          localValue = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Objetivos Ambientais',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
                              setModalState(() {
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
                              setModalState(() {
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _currentIndex == 0
            ? IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _openFilterModal,
              )
            : null,
        title: const Text('Home'),
        centerTitle: true,
      ),
      
      // O corpo muda conforme o índice selecionado
      body: _pages[_currentIndex],

      // AQUI ADICIONAS O TEU WIDGET CUSTOMIZADO
      // Ele vai ler automaticamente as cores do AppTheme que definiste
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}