import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/agizo_service.dart';
import '../../models/agizo.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class MaagizoScreen extends ConsumerStatefulWidget {
  const MaagizoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MaagizoScreen> createState() => _MaagizoScreenState();
}

class _MaagizoScreenState extends ConsumerState<MaagizoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maagizoAsync = ref.watch(maagizoListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        title: const Text('Maagizo Yangu',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        backgroundColor: const Color(0xFF0F1629),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF00C853),
          labelColor: const Color(0xFF00C853),
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Yote'),
            Tab(text: 'Yanasubiri'),
            Tab(text: 'Yanashughulikiwa'),
            Tab(text: 'Zimefika'),
          ],
        ),
      ),
      body: maagizoAsync.when(
        data: (maagizoList) {
          if (maagizoList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.receipt_long, size: 64, color: Colors.white54),
                  SizedBox(height: 16),
                  Text(
                    'Hakuna maagizo bado',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 16),
                  ),
                ],
              ),
            ).animate().fadeIn();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildMaagizoList(maagizoList),
              _buildMaagizoList(maagizoList
                  .where((a) => a.hali == AppConstants.orderPending)
                  .toList()),
              _buildMaagizoList(maagizoList
                  .where((a) => a.hali == AppConstants.orderProcessing)
                  .toList()),
              _buildMaagizoList(maagizoList
                  .where((a) => a.hali == AppConstants.orderDelivered)
                  .toList()),
            ],
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF00C853))),
        error: (err, stack) => Center(
            child: Text('Hitilafu: $err',
                style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildMaagizoList(List<AgizoModel> maagizo) {
    if (maagizo.isEmpty) {
      return const Center(
          child: Text('Hakuna maagizo katika kundi hili.',
              style:
                  TextStyle(color: Colors.white54, fontFamily: 'Poppins')));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: maagizo.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final agizo = maagizo[index];
        return InkWell(
          onTap: () => context.push('/maagizo/${agizo.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1629),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(agizo.mtejaMjina,
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    _buildStatusBadge(agizo.hali),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bidhaa ${agizo.bidhaa.length}',
                        style: const TextStyle(
                            color: Colors.white70, fontFamily: 'Poppins')),
                    Text(
                        AppHelpers.formatBei(agizo.jumla),
                        style: const TextStyle(
                            color: Color(0xFF00C853),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(AppHelpers.formatTarehe(agizo.iliyoundwa),
                    style: const TextStyle(
                        color: Colors.white38,
                        fontFamily: 'Poppins',
                        fontSize: 12)),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildStatusBadge(String hali) {
    Color color;
    switch (hali) {
      case AppConstants.orderPending:
        color = const Color(0xFFFFC107);
        break;
      case AppConstants.orderProcessing:
        color = const Color(0xFF00E5FF);
        break;
      case AppConstants.orderDelivered:
        color = const Color(0xFF00C853);
        break;
      case AppConstants.orderShipped:
        color = Colors.blueAccent;
        break;
      case AppConstants.orderCancelled:
        color = Colors.redAccent;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        hali,
        style: TextStyle(
            color: color,
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
