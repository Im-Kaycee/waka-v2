import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/gemini/gemini_service.dart';
import '../../core/gemini/prompt_builder.dart';
import '../../core/storage/hive_service.dart';
import '../../models/route_result.dart';
import '../../core/config.dart';

final _hiveService = HiveService();

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(_hiveService);
});

class HistoryState {
  final List<RouteResult> all;
  final List<RouteResult> filtered;
  final String query;
  final bool isLoading;
  final String? loadingRouteId;

  const HistoryState({
    this.all = const [],
    this.filtered = const [],
    this.query = '',
    this.isLoading = false,
    this.loadingRouteId,
  });

  HistoryState copyWith({
    List<RouteResult>? all,
    List<RouteResult>? filtered,
    String? query,
    bool? isLoading,
    String? loadingRouteId,
  }) {
    return HistoryState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      loadingRouteId: loadingRouteId,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final HiveService _hive;
  late final GeminiService _gemini;

  HistoryNotifier(this._hive) : super(const HistoryState()) {
    final promptBuilder = PromptBuilder(_hive);
    _gemini = GeminiService(promptBuilder, AppConfig.geminiApiKey);
    _load();
  }

  void _load() {
    final all = _hive.getRecentRoutes(limit: 100);
    state = state.copyWith(all: all, filtered: all);
  }

  void search(String query) {
    final filtered = query.isEmpty
        ? state.all
        : state.all.where((r) {
            final q = query.toLowerCase();
            return r.originLabel.toLowerCase().contains(q) ||
                r.destinationLabel.toLowerCase().contains(q);
          }).toList();
    state = state.copyWith(query: query, filtered: filtered);
  }

  Future<GeminiRouteResponse?> requery(RouteResult route) async {
    state = state.copyWith(isLoading: true, loadingRouteId: route.id);
    try {
      final response = await _gemini.resolveRoute(route.originalQuery);
      state = state.copyWith(isLoading: false, loadingRouteId: null);
      return response;
    } catch (e) {
      state = state.copyWith(isLoading: false, loadingRouteId: null);
      return null;
    }
  }
}

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(notifier),
            Expanded(
              child: state.filtered.isEmpty
                  ? _buildEmpty(state.query)
                  : _buildList(state, notifier, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF283618),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1a1a1a), width: 2.5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3EE),
                border: Border.all(color: const Color(0xFF1a1a1a), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF1a1a1a),
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 16,
                color: Color(0xFF1a1a1a),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RECENT ROUTES',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF5F3EE),
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'YOUR SEARCH HISTORY',
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
        ],
      ),
    );
  }

  Widget _buildSearchBar(HistoryNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1a1a1a), width: 2),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF1a1a1a), width: 2),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: 16,
              color: Color(0xFF888780),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: notifier.search,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1a1a1a),
                ),
                decoration: const InputDecoration(
                  hintText: 'Search routes...',
                  hintStyle: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 13,
                    color: Color(0xFFB4B2A9),
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  notifier.search('');
                },
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Color(0xFFB4B2A9),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF1a1a1a), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF1a1a1a),
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.route,
                size: 24,
                color: Color(0xFF888780),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              query.isEmpty
                  ? 'NO ROUTES YET'
                  : 'NO RESULTS FOR "$query"',
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF888780),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              query.isEmpty
                  ? 'Routes you search will appear here'
                  : 'Try a different origin or destination',
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 12,
                color: Color(0xFF888780),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    HistoryState state,
    HistoryNotifier notifier,
    BuildContext context,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.filtered.length,
      itemBuilder: (context, i) {
        final route = state.filtered[i];
        final isLoading = state.loadingRouteId == route.id;

        return GestureDetector(
          onTap: isLoading
              ? null
              : () async {
                  final response = await notifier.requery(route);
                  if (response != null && context.mounted) {
                    context.push('/result', extra: response);
                  }
                },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF1a1a1a), width: 2),
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
                      const SizedBox(height: 4),
                      Text(
                        '${route.stopLabels.length} stops · ${_formatDate(route.searchedAt)}',
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 11,
                          color: Color(0xFF888780),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Color(0xFF283618),
                      strokeWidth: 2,
                    ),
                  )
                else
                  const Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: Color(0xFF888780),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays}d ago';
  }
}


