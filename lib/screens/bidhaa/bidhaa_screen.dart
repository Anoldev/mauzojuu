import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/bidhaa_service.dart';
import '../../utils/helpers.dart';

class BidhaaScreen extends ConsumerWidget {
  const BidhaaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assuming bidhaaListProvider is defined in bidhaa_service.dart
    final bidhaaAsync = ref.watch(bidhaaListProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        title: const Text('Bidhaa Zangu', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        backgroundColor: const Color(0xFF0F1629),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/bidhaa/mpya'),
        backgroundColor: const Color(0xFF00C853),
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tafuta bidhaa...',
                hintStyle: const TextStyle(color: Colors.white54, fontFamily: 'Poppins'),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF0F1629),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(),
          Expanded(
            child: bidhaaAsync.when(
              data: (bidhaaList) {
                if (bidhaaList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white54),
                        const SizedBox(height: 16),
                        const Text(
                          'Bado hujaorodhesha bidhaa.\nOngeza ya kwanza!',
                          style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn();
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: bidhaaList.length,
                  itemBuilder: (context, index) {
                    final bidhaa = bidhaaList[index];
                    return Dismissible(
                      key: Key(bidhaa.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        // TODO: Implemet delete logic
                      },
                      child: GestureDetector(
                        onTap: () => context.push('/bidhaa/${bidhaa.id}'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1629),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: (bidhaa.pichaKuu.isNotEmpty)
                                      ? CachedNetworkImage(
                                          imageUrl: bidhaa.pichaKuu,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          placeholder: (context, url) => Container(color: Colors.white10),
                                          errorWidget: (context, url, error) => const Icon(Icons.image, color: Colors.white54),
                                        )
                                      : Container(
                                          color: Colors.white10,
                                          child: const Center(child: Icon(Icons.image, color: Colors.white54, size: 40)),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bidhaa.jina,
                                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppHelpers.formatBei(bidhaa.bei),
                                      style: const TextStyle(color: Color(0xFF00C853), fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Stock: ${bidhaa.idadi}',
                                        style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C853))),
              error: (err, stack) => Center(child: Text('Hitilafu: $err', style: const TextStyle(color: Colors.red, fontFamily: 'Poppins'))),
            ),
          )
        ],
      ),
    );
  }
}
