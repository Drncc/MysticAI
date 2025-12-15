import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:tekno_mistik/core/utils/content_moderator.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  // Mock Data - Initial Posts
  final List<Map<String, String>> _posts = [
    {"user": "Gezgin #4829", "content": "Bugün Aşıklar kartı çektim ve eski sevgilim aradı! Tesadüf mü?", "tag": "Tarot", "likes": "35", "comments": "7"},
    {"user": "Gezgin #1102", "content": "Meditasyon sırasında mor bir ışık gördüm. Anlamını bilen var mı?", "tag": "Meditasyon", "likes": "12", "comments": "3"},
    {"user": "Gezgin #9931", "content": "Kozmik mağazadaki Kahin paketini aldım, analizler inanılmaz detaylı.", "tag": "Deneyim", "likes": "28", "comments": "5"},
  ];

  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_path');
    });
  }

  void _addNewPost(String content) {
    setState(() {
      _posts.insert(0, {
        "user": "Ben (Gezgin)",
        "content": content,
        "tag": "Genel",
        "likes": "0",
        "comments": "0"
      });
    });
  }

  void _showPostDialog(BuildContext context) {
    final TextEditingController postController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Klavye için kritik
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Klavye payı
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C).withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: const Border(top: BorderSide(color: Colors.purpleAccent, width: 1)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white10,
                      backgroundImage: _profileImagePath != null
                          ? FileImage(File(_profileImagePath!)) as ImageProvider
                          : const AssetImage('assets/tarot/0_fool_1.jpg'),
                    ),
                    const SizedBox(width: 15),
                    Text("EVRENE MESAJ BIRAK", style: AppTheme.orbitronStyle.copyWith(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: postController,
                  style: GoogleFonts.inter(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Bugün yıldızlar sana ne fısıldadı?...",
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: Colors.black54,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    onPressed: () {
                      if (postController.text.isNotEmpty) {
                        // 1. KONTROL: Güvenli mi?
                        if (ContentModerator.isSafe(postController.text)) {
                          _addNewPost(postController.text);
                          Navigator.pop(context);
                        } else {
                          // YASAKLI: Uyarı Ver
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF1E1E2C),
                              title: Text("Negatif Enerji Tespit Edildi", style: AppTheme.orbitronStyle.copyWith(color: AppTheme.errorRed, fontSize: 16)),
                              content: Text("Mesajın, kozmik topluluk kurallarımıza uymayan kelimeler içeriyor. Lütfen ifadelerini arındır.", style: GoogleFonts.inter(color: Colors.white70)),
                              actions: [
                                TextButton(child: Text("TAMAM", style: TextStyle(color: AppTheme.neonCyan)), onPressed: () => Navigator.pop(ctx)),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    child: Text("SİNYALİ GÖNDER", style: AppTheme.orbitronStyle.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100), // Nav bar clearance
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // SECTION 1: ASTROLOGER INSIGHTS as previously implemented
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("YILDIZ REHBERLERİ", style: AppTheme.orbitronStyle.copyWith(color: AppTheme.neonCyan, fontSize: 14, letterSpacing: 1)),
              ).animate().fadeIn().slideX(),
              const SizedBox(height: 15),
              
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    _buildAstrologerAvatar(context, "Astrolog Meral", "assets/avatars/meral.jpg", Colors.purpleAccent, "Bugün Mars retrosu etkilerini sert hissettirebilir. Ani kararlardan kaçın."),
                    _buildAstrologerAvatar(context, "Dr. Kozmos", "assets/avatars/kozmos.jpg", Colors.blueAccent, "Schumann rezonansında ani bir yükseliş var. Baş ağrılarına dikkat."),
                    _buildAstrologerAvatar(context, "Maya Kahini", "assets/avatars/maya.jpg", Colors.amberAccent, "Rüyalarınızın rehberliğine güvenin. Evren size fısıldıyor."),
                    _buildAstrologerAvatar(context, "Simyacı", "assets/avatars/alchemist.jpg", Colors.greenAccent, "Dönüşüm sancılıdır ama gereklidir. Eski kabuğunuzu atın."),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // SECTION 2: TRAVELER FEED
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("GEZGİN AKIŞI", style: AppTheme.orbitronStyle.copyWith(color: AppTheme.neonPurple, fontSize: 14, letterSpacing: 1)),
              ).animate().fadeIn(delay: 200.ms).slideX(),
              const SizedBox(height: 15),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                   final post = _posts[index];
                   return SocialPostCard(
                     username: post["user"] ?? "Gezgin",
                     content: post["content"] ?? "",
                     tag: post["tag"] ?? "Genel",
                     initialLikes: int.tryParse(post["likes"] ?? "0") ?? 0,
                     initialComments: int.tryParse(post["comments"] ?? "0") ?? 0,
                   ).animate(delay: (100).ms).fadeIn().slideY(begin: 0.2);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0, right: 10.0), // Navigasyon Bar'ın üzerine çıkar
        child: FloatingActionButton(
          backgroundColor: Colors.transparent, // Gradient için şeffaf
          elevation: 10,
          onPressed: () => _showPostDialog(context), // Fonksiyonu tetikle
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.purpleAccent, Colors.cyanAccent]),
            ),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildAstrologerAvatar(BuildContext context, String name, String assetPath, Color glowColor, String dailyMessage) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              border: Border(top: BorderSide(color: glowColor, width: 2)),
            ),
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: AppTheme.orbitronStyle.copyWith(fontSize: 20, color: glowColor)),
                const SizedBox(height: 20),
                Text(
                  dailyMessage,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 16, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white10,
                border: Border.all(color: glowColor.withOpacity(0.5), width: 2),
                boxShadow: [BoxShadow(color: glowColor.withOpacity(0.2), blurRadius: 10)],
                image: DecorationImage(
                   // Placeholder logic since user asked for Mock Images
                   image: const NetworkImage("https://picsum.photos/100"), 
                   fit: BoxFit.cover
                )
              ),
              child: const Center(child: Icon(Icons.person, color: Colors.white38)), // Fallback if network fails
            ),
            const SizedBox(height: 8),
            Text(name, style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class SocialPostCard extends StatefulWidget {
  final String username;
  final String content;
  final int initialLikes;
  final int initialComments;
  final String tag;

  const SocialPostCard({
    super.key,
    required this.username,
    required this.content,
    required this.initialLikes,
    required this.initialComments,
    required this.tag,
  });

  @override
  State<SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends State<SocialPostCard> {
  late bool isLiked;
  late int likeCount;
  late List<Map<String, String>> comments;

  @override
  void initState() {
    super.initState();
    isLiked = false; // Varsayılan: Beğenilmemiş
    likeCount = widget.initialLikes;
    // Mock Comments (Sayıya göre fake üret)
    comments = List.generate(widget.initialComments, (index) => {
      'user': 'Gezgin #${1000 + index}',
      'text': index % 2 == 0 ? 'Harika bir enerji!' : 'Bunu hissettim...'
    });
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Text("Enerji İhlali Bildirimi", style: AppTheme.orbitronStyle.copyWith(color: AppTheme.errorRed, fontSize: 16)),
        content: Text("Bu paylaşım kozmik topluluk kurallarını ihlal mi ediyor? Bildirimin anonim olarak incelenecektir.", style: GoogleFonts.inter(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text("VAZGEÇ", style: TextStyle(color: Colors.grey)), 
            onPressed: () => Navigator.pop(ctx)
          ),
          TextButton(
            child: const Text("BİLDİR", style: TextStyle(color: AppTheme.neonCyan)), 
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bildiriminiz Kozmik Konseye iletildi.")));
            }
          ),
        ],
      ),
    );
  }

  void _showCommentDialog() {
    TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7, // %70 Ekran
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E2C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(top: BorderSide(color: Colors.cyanAccent, width: 1))
              ),
              child: Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text("Yorumlar", style: AppTheme.orbitronStyle.copyWith(color: Colors.white)),
                  ),
                  const Divider(color: Colors.white10),

                  // COMMENT LIST
                  Expanded(
                    child: ListView.builder(
                      itemCount: comments.length,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.neonPurple.withOpacity(0.2),
                            radius: 15,
                            child: const Icon(Icons.person, color: Colors.cyanAccent, size: 20),
                          ),
                          title: Text(comment['user'] ?? 'Anonim', style: const TextStyle(color: Colors.cyanAccent, fontSize: 12)),
                          subtitle: Text(comment['text'] ?? '', style: GoogleFonts.inter(color: Colors.white70)),
                        );
                      },
                    ),
                  ),

                  // INPUT AREA
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Yorumun...",
                              hintStyle: const TextStyle(color: Colors.white30),
                              filled: true,
                              fillColor: Colors.black45,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.purpleAccent),
                          onPressed: () {
                            if (commentController.text.isNotEmpty) {
                              if (ContentModerator.isSafe(commentController.text)) {
                                setModalState(() {
                                  comments.add({
                                    "user": "Ben",
                                    "text": commentController.text
                                  });
                                });
                                // Parent state'i de güncelle ki sayı değişsin
                                setState(() {}); 
                                commentController.clear();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu yorum kozmik kurallara uymuyor!"), backgroundColor: Colors.red));
                              }
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GlassCard(
        color: Colors.white.withOpacity(0.03),
        borderColor: Colors.white.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  CircleAvatar(radius: 12, backgroundColor: Colors.white24, child: const Icon(Icons.person, size: 14, color: Colors.white)),
                  const SizedBox(width: 8),
                  Text(widget.username, style: AppTheme.orbitronStyle.copyWith(color: AppTheme.neonCyan, fontSize: 12)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.neonPurple.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(widget.tag, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  )
                ],
              ),
              const SizedBox(height: 10),
              // CONTENT
              Text(
                widget.content,
                style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 15),
              // ACTIONS
              Row(
                children: [
                  // LIKE BUTTON
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLiked = !isLiked;
                        likeCount += isLiked ? 1 : -1;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.redAccent : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text("$likeCount", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 20),

                  // COMMENT BUTTON
                  GestureDetector(
                    onTap: _showCommentDialog,
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20),
                        const SizedBox(width: 5),
                        Text("${comments.length}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // REPORT BUTTON
                  IconButton(
                    icon: const Icon(Icons.flag_outlined, color: Colors.white38, size: 20),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: _showReportDialog,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
