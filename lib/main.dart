import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anggota Kelompok',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'sans-serif'),
      home: const GroupMembersPage(),
    );
  }
}

// ============================================================
// DATA ANGGOTA — ISI MANUAL DI SINI
// ============================================================

class Member {
  final String name; // Nama lengkap
  final String nim; // NIM / ID anggota
  final String role; // Peran dalam kelompok (contoh: Ketua, Anggota)
  final String quote; // Kata-kata / motto singkat
  final Color cardColor; // Warna aksen kartu
  final IconData icon; // Ikon representatif

  const Member({
    required this.name,
    required this.nim,
    required this.role,
    required this.quote,
    required this.cardColor,
    required this.icon,
  });
}

final List<Member> members = [
  // ── ANGGOTA 1 ──────────────────────────────────────────
  Member(
    name: 'Nawa ', // TODO: ganti nama
    nim: 'NIM / ID 1', // TODO: ganti NIM
    role: 'Ketua', // TODO: ganti peran
    quote: '"Tulis motto di sini"', // TODO: ganti quote
    cardColor: const Color(0xFF6C63FF),
    icon: Icons.person,
  ),

  // ── ANGGOTA 2 ──────────────────────────────────────────
  Member(
    name: 'Nama Anggota 2', // TODO: ganti nama
    nim: 'NIM / ID 2', // TODO: ganti NIM
    role: 'Sekretaris', // TODO: ganti peran
    quote: '"Tulis motto di sini"', // TODO: ganti quote
    cardColor: const Color(0xFF43BCA8),
    icon: Icons.person,
  ),

  // ── ANGGOTA 3 ──────────────────────────────────────────
  Member(
    name: 'Fauzi Maulana Akbar', // TODO: ganti nama
    nim: '230102049', // TODO: ganti NIM
    role: 'Belakang', // TODO: ganti peran
    quote: '"Kesana Kemari"', // TODO: ganti quote
    cardColor: const Color(0xFFFF6B6B),
    icon: Icons.person,
  ),

  // ── ANGGOTA 4 ──────────────────────────────────────────
  Member(
    name: 'Nama Anggota 4', // TODO: ganti nama
    nim: 'NIM / ID 4', // TODO: ganti NIM
    role: 'Anggota', // TODO: ganti peran
    quote: '"Tulis motto di sini"', // TODO: ganti quote
    cardColor: const Color(0xFFF7C948),
    icon: Icons.person,
  ),
];

// ============================================================
// HALAMAN UTAMA
// ============================================================

class GroupMembersPage extends StatefulWidget {
  const GroupMembersPage({super.key});

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          ),
        );
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildMemberCard(index),
                  childCount: members.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600
                      ? 2
                      : 1,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: MediaQuery.of(context).size.width > 600
                      ? 1.15
                      : 1.6,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildFooter()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerFade,
      child: SlideTransition(
        position: _headerSlide,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: const Text(
                  '✦  Kelompok Kami', // TODO: ganti nama kelompok jika ada
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tim\nHebat Kami', // TODO: ganti judul jika perlu
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                // TODO: ganti deskripsi kelompok
                'Berkenalan dengan anggota kelompok kami.\nKetuk kartu untuk melihat detail lengkap.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + index * 120),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value.clamp(0, 1), child: child),
        );
      },
      child: _FlipCard(member: members[index]),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Center(
        child: Text(
          '${members.length} Anggota · Tap kartu untuk flip ↩',
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FLIP CARD WIDGET
// ============================================================

class _FlipCard extends StatefulWidget {
  final Member member;
  const _FlipCard({required this.member});

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value;
          final isFrontVisible = angle < math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFrontVisible
                ? _CardFront(member: widget.member)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardBack(member: widget.member),
                  ),
          );
        },
      ),
    );
  }
}

// ── SISI DEPAN ──────────────────────────────────────────────

class _CardFront extends StatelessWidget {
  final Member member;
  const _CardFront({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [member.cardColor.withOpacity(0.25), const Color(0xFF1A1A2E)],
        ),
        border: Border.all(
          color: member.cardColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: member.cardColor.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar circle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        member.cardColor.withOpacity(0.6),
                        member.cardColor.withOpacity(0.2),
                      ],
                    ),
                    border: Border.all(
                      color: member.cardColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(member.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: member.cardColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          member.role.toUpperCase(),
                          style: TextStyle(
                            color: member.cardColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(height: 1, color: Colors.white.withOpacity(0.08)),
            const SizedBox(height: 12),
            Text(
              member.nim,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 12,
                  color: member.cardColor.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  'Ketuk untuk detail',
                  style: TextStyle(
                    color: member.cardColor.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── SISI BELAKANG ───────────────────────────────────────────

class _CardBack extends StatelessWidget {
  final Member member;
  const _CardBack({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: member.cardColor.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: member.cardColor.withOpacity(0.3),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -15,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TENTANG SAYA',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  member.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  member.quote,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.badge_outlined,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        member.nim,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'monospace',
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.flip_outlined,
                      size: 11,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ketuk untuk kembali',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
