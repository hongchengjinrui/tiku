import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../data/local/resource_cache_storage.dart';
import '../../data/mock/mock_app_store.dart';
import '../../data/repositories/remote_tiku_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../core/app_scaffold.dart';
import '../../core/widgets.dart';

/// P40 资料中心页
class P40ResourceCenterPage extends StatefulWidget {
  const P40ResourceCenterPage({super.key});

  @override
  State<P40ResourceCenterPage> createState() => _P40ResourceCenterPageState();
}

class _P40ResourceCenterPageState extends State<P40ResourceCenterPage> {
  late Future<List<_ResourceItem>> _resourcesFuture;
  late bool _lastRemoteReady;

  @override
  void initState() {
    super.initState();
    _lastRemoteReady = mockStore.remoteReady;
    _resourcesFuture = _loadResources();
    mockStore.addListener(_handleStoreChanged);
  }

  @override
  void dispose() {
    mockStore.removeListener(_handleStoreChanged);
    super.dispose();
  }

  void _handleStoreChanged() {
    final remoteReady = mockStore.remoteReady;
    if (remoteReady == _lastRemoteReady) return;
    _lastRemoteReady = remoteReady;
    if (!remoteReady || !mounted) return;
    setState(() => _resourcesFuture = _loadResources());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '资料'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CacheStatusBanner(
                      store: mockStore,
                      margin: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    _buildRightsCard(),
                    const SizedBox(height: 14),
                    _buildResourceList(),
                    const SizedBox(height: 10),
                    _buildMoreHint(),
                  ],
                ),
              ),
            ),
            const BottomTabBar(currentIndex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildRightsCard() {
    return AnimatedBuilder(
      animation: mockStore,
      builder: (context, _) {
        final subjectName = mockStore.selectedSubject.name;
        return FutureBuilder<List<_ResourceItem>>(
          future: _resourcesFuture,
          builder: (context, snapshot) {
            final source = snapshot.data ?? _fallbackResources;
            final resources = mockStore.remoteReady
                ? _resourcesForSubject(source, subjectName)
                : source;
            final freeCount = resources.where((item) => item.isFree).length;
            final vipCount = resources.length - freeCount;
            final summary = resources.isEmpty
                ? '当前科目暂无备考资料'
                : '$vipCount份VIP备考资料 + $freeCount份免费备考资料';
            return Container(
              width: double.infinity,
              height: 86,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryLight, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subjectName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const SizedBox(height: 6),
                        Text(summary.replaceAll(' + ', '+'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.textBlueHint)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push('/practice/switch-subject'),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 88,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('切换科目',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResourceList() {
    return AnimatedBuilder(
      animation: mockStore,
      builder: (context, _) {
        return FutureBuilder<List<_ResourceItem>>(
          future: _resourcesFuture,
          builder: (context, snapshot) {
            final source = snapshot.data ?? _fallbackResources;
            final resources = mockStore.remoteReady
                ? _resourcesForSubject(source, mockStore.selectedSubject.name)
                : source;
            if (resources.isEmpty) return _buildEmptyResources(context);
            return Column(
              children: [
                for (var index = 0; index < resources.length; index++) ...[
                  _buildResourceCard(context, resources[index]),
                  if (index < resources.length - 1) const SizedBox(height: 10),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyResources(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.folder_off_outlined,
              size: 34, color: AppColors.textMuted),
          const SizedBox(height: 10),
          const Text('当前科目暂无资料',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => context.push('/practice/switch-subject'),
            icon: const Icon(Icons.swap_horiz, size: 17),
            label: const Text('切换科目'),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, _ResourceItem resource) {
    final icon =
        resource.isFree ? Icons.description_outlined : Icons.workspace_premium;
    final iconColor =
        resource.isFree ? AppColors.success : const Color(0xFFD6A84A);
    final claimCount = mockStore.resourceClaimCount(resource.trackingId);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _activeResource = resource;
        context.push(resource.isFree ? '/resources/free' : '/resources/paid');
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 112),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(resource.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text(resource.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 66,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: resource.isFree
                          ? AppColors.successBg
                          : const Color(0xFFFFF9DF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(resource.isFree ? '免费' : 'VIP',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: resource.isFree
                                ? AppColors.success
                                : const Color(0xFF8A5B16))),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    claimCount > 0 ? '已领取$claimCount次' : '去领取',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight:
                          claimCount > 0 ? FontWeight.w600 : FontWeight.w400,
                      color: claimCount > 0
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.textMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreHint() {
    return Container(
      width: double.infinity,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('更多资料持续更新中',
          style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary)),
    );
  }
}

Future<List<_ResourceItem>> _loadResources() async {
  final cached = await _readCachedResources();
  if (!mockStore.remoteReady) {
    return cached.isNotEmpty ? cached : _fallbackResources;
  }
  try {
    final dio = Dio(
      BaseOptions(
        baseUrl: defaultApiBaseUrl,
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 6),
      ),
    );
    final response = await dio.get<List<dynamic>>(
      '/client/resources',
      queryParameters: {'appKey': defaultAppKey},
    );
    final items = (response.data ?? []).whereType<Map<String, dynamic>>();
    final parsed = items.map((item) {
      final accessType = item['accessType']?.toString() ?? 'free';
      final fileType = (item['fileType'] ?? 'PDF').toString().toUpperCase();
      final subject = item['subjectName']?.toString();
      final pages = (item['pages'] as List<dynamic>? ?? [])
          .map((page) => page.toString())
          .where((page) => page.trim().isNotEmpty)
          .toList();
      return _ResourceItem(
        id: item['id']?.toString() ?? '',
        title: item['title']?.toString() ?? '备考资料',
        subjectName: subject,
        description: item['description']?.toString(),
        fileType: fileType,
        fileUrl: item['fileUrl']?.toString(),
        pages: pages.isEmpty ? const [] : pages,
        isFree: accessType == 'free',
        unlocked: item['unlocked'] == true,
      );
    }).toList();
    if (parsed.isNotEmpty) {
      await _writeCachedResources(parsed);
      return parsed;
    }
    return cached.isNotEmpty ? cached : _fallbackResources;
  } catch (_) {
    return cached.isNotEmpty ? cached : _fallbackResources;
  }
}

Future<List<_ResourceItem>> _readCachedResources() async {
  try {
    final file = await resourceCacheFile();
    if (!await file.exists()) return const [];
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((item) => _ResourceItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  } catch (_) {
    return const [];
  }
}

Future<void> _writeCachedResources(List<_ResourceItem> resources) async {
  try {
    final file = await resourceCacheFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode(resources.map((item) => item.toJson()).toList()),
    );
  } catch (_) {}
}

List<_ResourceItem> _resourcesForSubject(
  List<_ResourceItem> resources,
  String subjectName,
) {
  final normalizedSubject = subjectName.trim();
  return resources.where((resource) {
    final resourceSubject = resource.subjectName?.trim() ?? '';
    return resourceSubject.isEmpty || resourceSubject == normalizedSubject;
  }).toList();
}

const _fallbackResources = [
  _ResourceItem(
    id: 'fallback_free',
    title: '入门备考规划清单',
    subjectName: '综合类',
    description: '免费领取资料，本地开发阶段开放完整预览。',
    fileType: 'PDF',
    fileUrl: 'local://入门备考规划清单',
    pages: [
      '入门备考规划清单 第 1 页：备考时间规划。',
      '入门备考规划清单 第 2 页：章节练习节奏。',
      '入门备考规划清单 第 3 页：冲刺复盘清单。',
    ],
    isFree: true,
    unlocked: true,
  ),
  _ResourceItem(
    id: 'fallback_vip_1',
    title: '教育基础高频考点速记',
    subjectName: '综合类',
    description: 'VIP 备考资料，未接登录前本地开发阶段开放完整预览。',
    fileType: 'DOCX',
    fileUrl: 'local://教育基础高频考点速记',
    pages: [
      '教育基础高频考点速记 第 1 页：核心知识导览。',
      '教育基础高频考点速记 第 2 页：高频考点整理。',
      '教育基础高频考点速记 第 3 页：练前复盘清单。',
    ],
    isFree: false,
    unlocked: true,
  ),
  _ResourceItem(
    id: 'fallback_vip_2',
    title: '历年真题汇编（2020-2025）',
    subjectName: '综合类',
    description: 'VIP 备考资料，未接登录前本地开发阶段开放完整预览。',
    fileType: 'PDF',
    fileUrl: 'local://历年真题汇编（2020-2025）',
    pages: [
      '历年真题汇编 第 1 页：题型分布。',
      '历年真题汇编 第 2 页：真题精选。',
      '历年真题汇编 第 3 页：答案解析。',
    ],
    isFree: false,
    unlocked: true,
  ),
];

class _ResourceItem {
  final String id;
  final String title;
  final String? subjectName;
  final String? description;
  final String fileType;
  final String? fileUrl;
  final List<String> pages;
  final bool isFree;
  final bool unlocked;

  const _ResourceItem({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.description,
    required this.fileType,
    required this.fileUrl,
    required this.pages,
    required this.isFree,
    required this.unlocked,
  });

  factory _ResourceItem.fromJson(Map<String, dynamic> json) {
    return _ResourceItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '备考资料',
      subjectName: json['subjectName']?.toString(),
      description: json['description']?.toString(),
      fileType: json['fileType']?.toString() ?? 'PDF',
      fileUrl: json['fileUrl']?.toString(),
      pages: (json['pages'] as List<dynamic>? ?? [])
          .map((page) => page.toString())
          .where((page) => page.trim().isNotEmpty)
          .toList(),
      isFree: json['isFree'] == true,
      unlocked: json['unlocked'] == true,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'subjectName': subjectName,
      'description': description,
      'fileType': fileType,
      'fileUrl': fileUrl,
      'pages': pages,
      'isFree': isFree,
      'unlocked': unlocked,
    };
  }

  String get subtitle {
    final access = isFree ? '免费' : 'VIP';
    final subject = subjectName?.trim();
    final pageText = pages.isEmpty ? '在线文档' : '${pages.length}页';
    return '$access · $fileType · $pageText${subject == null || subject.isEmpty ? '' : ' · $subject'}';
  }

  String get trackingId => id.trim().isEmpty ? title : id.trim();
}

_ResourceItem? _activeResource;

/// P41 付费资料预览页
class P41PaidResourcePreviewPage extends StatelessWidget {
  const P41PaidResourcePreviewPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const _ResourceDocumentScaffold(preferFree: false);
}

/// P40A 免费资料详情页
class P40AFreeResourceDetailPage extends StatelessWidget {
  const P40AFreeResourceDetailPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const _ResourceDocumentScaffold(preferFree: true);
}

class _ResourceDocumentScaffold extends StatefulWidget {
  final bool preferFree;

  const _ResourceDocumentScaffold({required this.preferFree});

  @override
  State<_ResourceDocumentScaffold> createState() =>
      _ResourceDocumentScaffoldState();
}

class _ResourceDocumentScaffoldState extends State<_ResourceDocumentScaffold> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _ResourceItem get _defaultResource {
    return _fallbackResources.firstWhere(
      (resource) => resource.isFree == widget.preferFree,
      orElse: () => _fallbackResources.first,
    );
  }

  _ResourceItem get _resolvedResource {
    final active = _activeResource;
    if (active != null && active.isFree == widget.preferFree) return active;
    return _defaultResource;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mockStore,
      builder: (context, _) {
        final resource = _resolvedResource;
        final pages = resource.pages.isEmpty
            ? ['${resource.title}\n\n${resource.description ?? '资料内容待同步。'}']
            : resource.pages;
        final claimCount = mockStore.resourceClaimCount(resource.trackingId);
        final safePage = _currentPage.clamp(0, pages.length - 1);
        return Scaffold(
          body: SizedBox(
            width: 390,
            child: Column(
              children: [
                const StatusBar(),
                NavBar(title: resource.title),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (value) =>
                        setState(() => _currentPage = value),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                      child: _DocumentPage(
                        text: pages[index],
                      ),
                    ),
                  ),
                ),
                Text(
                  '${safePage + 1} / ${pages.length}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final link = resource.fileUrl?.trim().isNotEmpty == true
                          ? resource.fileUrl!.trim()
                          : resource.title;
                      mockStore.claimResourceDownloadLink(
                        resourceId: resource.trackingId,
                        title: resource.title,
                        link: link,
                        subjectName: resource.subjectName,
                        isFree: resource.isFree,
                      );
                      await Clipboard.setData(ClipboardData(text: link));
                      if (context.mounted) {
                        P40BLinkCopiedToast.show(context);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.link, size: 20, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(claimCount > 0 ? '再次获取下载链接' : '获取下载链接',
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DocumentPage extends StatelessWidget {
  final String text;

  const _DocumentPage({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 260),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                height: 1.8,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// P42 已解锁资料详情页
class P42UnlockedResourceDetailPage extends StatelessWidget {
  const P42UnlockedResourceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            const NavBar(title: '教育基础高频考点速记'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    _buildUnlockedCard(),
                    const SizedBox(height: 14),
                    const Text('资料内容',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                          '教育基础高频考点速记\n\n第一章 教育与教育学\n教育学是研究教育现象和教育问题...\n\n第二章 教育目的\n教育目的是教育工作的出发点和归宿...',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              height: 1.8,
                              color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        const link = 'local://教育基础高频考点速记';
                        mockStore.claimResourceDownloadLink(
                          resourceId: 'fallback_vip_1',
                          title: '教育基础高频考点速记',
                          link: link,
                          subjectName: mockStore.selectedSubject.name,
                          isFree: false,
                        );
                        await Clipboard.setData(
                            const ClipboardData(text: link));
                        if (context.mounted) {
                          P40BLinkCopiedToast.show(context);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.download, size: 20, color: Colors.white),
                            SizedBox(width: 8),
                            Text('下载资料',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockedCard() {
    return Container(
      width: double.infinity,
      height: 104,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('教育基础高频考点速记',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              SizedBox(height: 7),
              Text('VIP专享 · 已解锁',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.success)),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(22),
            ),
            child:
                const Icon(Icons.lock_open, size: 20, color: AppColors.success),
          ),
        ],
      ),
    );
  }
}

/// P41A 开放体验说明页
class P41AVipPage extends StatelessWidget {
  const P41AVipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            // 导航栏
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _closeVipPage(context),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(Icons.chevron_left,
                          size: 24, color: Color(0xFF8A5B16)),
                    ),
                  ),
                  const Expanded(
                    child: Text('开放体验',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8A5B16))),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // VIP Hero卡
                    Container(
                      width: double.infinity,
                      height: 111,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFF9DF),
                            Color(0xFFFFE8A8),
                            Color(0xFFF3D37B),
                          ],
                          stops: [0, 0.62, 1],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 18,
                            top: 29,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('开放体验模式',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF8A5B16))),
                                SizedBox(height: 6),
                                Text('登录、支付、VIP 将在上架前统一接入',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        color: Color(0xFF8A5B16))),
                              ],
                            ),
                          ),
                          const Positioned(
                            right: 20,
                            top: 25,
                            child: Icon(Icons.workspace_premium,
                                size: 60, color: Color(0x33D6A84A)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('当前开放范围',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8A5B16))),
                    const SizedBox(height: 10),
                    _buildBenefitsGrid(),
                    const SizedBox(height: 14),
                    const Text('后续接入范围',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8A5B16))),
                    const SizedBox(height: 8),
                    _buildPlanRow(),
                    const SizedBox(height: 14),
                    _buildOpenExperienceNotice(),
                  ],
                ),
              ),
            ),
            // 底部开放体验返回栏
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 12, bottom: 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border:
                    Border(top: BorderSide(color: Color(0xFFF4DEAA), width: 1)),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.go('/resources'),
                child: Container(
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1BE),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Color(0xFFE8BD58)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('返回资料中心',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8A5B16))),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward,
                          size: 18, color: Color(0xFF8A5B16)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _closeVipPage(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    context.go('/resources');
  }

  Widget _buildBenefitsGrid() {
    final benefits = [
      {'icon': Icons.library_books, 'title': '全部资料', 'desc': '完整预览下载'},
      {'icon': Icons.all_inclusive, 'title': '练习考试', 'desc': '本地完整体验'},
      {'icon': Icons.analytics, 'title': '学习记录', 'desc': '本地持续保存'},
      {'icon': Icons.block, 'title': '权限判断', 'desc': '当前暂不启用'},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: benefits.length,
      itemBuilder: (context, i) {
        final b = benefits[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(b['icon'] as IconData,
                  size: 20, color: const Color(0xFF8A5B16)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(b['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8A5B16))),
                    Text(b['desc'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlanRow() {
    final plans = [
      {'name': '登录', 'status': '上架前接入'},
      {'name': '支付', 'status': '上架前接入', 'best': true},
      {'name': 'VIP', 'status': '上架前接入'},
    ];
    return Row(
      children: plans.map((p) {
        final isBest = p['best'] == true;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: isBest ? const Color(0xFFFFF1BE) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isBest ? const Color(0xFFE8BD58) : AppColors.border,
                    width: isBest ? 2 : 1),
              ),
              child: Stack(
                children: [
                  if (isBest)
                    Positioned(
                      right: 8,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8A5B16),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('后续',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                color: Colors.white)),
                      ),
                    ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p['name'] as String,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8A5B16))),
                        const SizedBox(height: 4),
                        Text(p['status'] as String,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOpenExperienceNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF4DEAA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, size: 18, color: Color(0xFF8A5B16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '当前版本不接入登录、支付、VIP 权限判断。所有资料在本地体验阶段均可完整预览，并可直接获取下载链接。',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                height: 1.55,
                color: Color(0xFF8A5B16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// P40B 免费资料链接复制Toast
class P40BLinkCopiedToast {
  static void show(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text('资料连接已经复制',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// P40B 免费资料链接复制 Toast 状态页
class P40BLinkCopiedToastPage extends StatelessWidget {
  const P40BLinkCopiedToastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SizedBox(
        width: 390,
        child: Stack(
          children: [
            const P40AFreeResourceDetailPage(),
            Positioned(
              left: 50,
              right: 50,
              bottom: 36,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      '资料连接已经复制',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// P59A 开放体验提示页（支付/VIP 上架前不接入）
class P59APaymentSuccessPage extends StatelessWidget {
  const P59APaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SizedBox(
        width: 390,
        child: Column(
          children: [
            const StatusBar(),
            NavBar(
              title: '开放体验',
              onBack: () => context.go('/resources'),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF4DEAA)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.successBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_open,
                                size: 40, color: AppColors.success),
                          ),
                          const SizedBox(height: 16),
                          const Text('当前为开放体验模式',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          const Text('登录、支付、VIP 将在上架前统一接入',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // 权益摘要
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('当前阶段所有资料均开放完整预览，可直接获取下载链接。',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppColors.textPrimary)),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.go('/resources'),
                            child: Container(
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Text('返回资料',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      color: AppColors.textPrimary)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.go('/practice'),
                            child: Container(
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('继续刷题',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
