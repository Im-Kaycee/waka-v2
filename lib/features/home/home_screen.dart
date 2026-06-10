import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'home_controller.dart';
import '../../widgets/field_row.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchFields(context, state, controller),
                    const SizedBox(height: 32),
                    _buildRecentRoutes(context, state, controller),
                    const SizedBox(height: 32),
                    _buildLandmarks(state),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF283618),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1a1a1a), width: 2.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF5F3EE),
                letterSpacing: -1,
              ),
              children: [
                TextSpan(text: 'WA'),
                TextSpan(
                  text: 'K',
                  style: TextStyle(
                    color: Color(0xFFD4E8B0),
                  ),
                ),
                TextSpan(text: 'A'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'NAVIGATE ABUJA, THE LOCAL WAY',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8FAF6A),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFields(
    BuildContext context,
    HomeState state,
    HomeController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WHERE ARE YOU GOING?',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF888780),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        FieldRow(
          controller: _fromController,
          hint: 'From — e.g. Airport Road',
          dotColor: const Color(0xFF1a1a1a),
          onChanged: controller.setFrom,
          onClear: () {
            _fromController.clear();
            controller.setFrom('');
          },
        ),
        Container(
          margin: const EdgeInsets.only(left: 20),
          width: 2,
          height: 12,
          color: const Color(0xFF1a1a1a),
        ),
        FieldRow(
          controller: _toController,
          hint: 'To — e.g. Zone 3 secretariat',
          dotColor: const Color(0xFF283618),
          onChanged: controller.setTo,
          onClear: () {
            _toController.clear();
            controller.setTo('');
          },
        ),
        const SizedBox(height: 16),
        if (state.error != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFCEBEB),
              border: Border.all(color: const Color(0xFFA32D2D), width: 2),
            ),
            child: Text(
              state.error!,
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 12,
                color: Color(0xFFA32D2D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        GestureDetector(
          onTap: state.isLoading
              ? null
              : () => _search(context, controller, state),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: state.isLoading
                  ? const Color(0xFF283618).withOpacity(0.7)
                  : const Color(0xFF283618),
              border: Border.all(color: const Color(0xFF1a1a1a), width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF1a1a1a),
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Color(0xFFF5F3EE),
                      strokeWidth: 2,
                    ),
                  )
                else
                  const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFFF5F3EE),
                    size: 16,
                  ),
                const SizedBox(width: 10),
                Text(
                  state.isLoading ? 'FINDING ROUTE...' : 'FIND ROUTE',
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF5F3EE),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRoutes(
    BuildContext context,
    HomeState state,
    HomeController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENT ROUTES',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF888780),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        if (state.recentRoutes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD3D1C7), width: 2),
            ),
            child: const Text(
              'No recent routes yet. Search one above.',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 12,
                color: Color(0xFF888780),
              ),
            ),
          )
        else
          ...state.recentRoutes.map((route) => GestureDetector(
                onTap: () async {
                  final response = await controller.requery(route);
                  if (response != null && context.mounted) {
                    context.push('/result', extra: response);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: const Color(0xFF1a1a1a), width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF1a1a1a),
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${route.originLabel} → ${route.destinationLabel}',
                              style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1a1a1a),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${route.stopLabels.length} stops',
                              style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 11,
                                color: Color(0xFF888780),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Color(0xFF888780),
                      ),
                    ],
                  ),
                ),
              )),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => context.push('/history'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF1a1a1a), width: 2),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'VIEW ALL ROUTES',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a1a),
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 12, color: Color(0xFF1a1a1a)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandmarks(HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'KNOWN LANDMARKS',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF888780),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...state.landmarks.map(
              (l) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: l.verified
                      ? const Color(0xFF283618)
                      : Colors.white,
                  border: Border.all(
                      color: const Color(0xFF1a1a1a), width: 2),
                ),
                child: Text(
                  l.localName,
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: l.verified
                        ? const Color(0xFFF5F3EE)
                        : const Color(0xFF1a1a1a),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3EE),
                  border: Border.all(
                      color: const Color(0xFFD3D1C7), width: 2),
                ),
                child: const Text(
                  '+ add place',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11,
                    color: Color(0xFF888780),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _search(
    BuildContext context,
    HomeController controller,
    HomeState state,
  ) async {
    if (state.from.isEmpty || state.to.isEmpty) return;
    final response = await controller.search();
    if (response != null && context.mounted) {
      context.push('/result', extra: response);
    }
  }
}