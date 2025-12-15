import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tekno_mistik/core/presentation/widgets/glass_card.dart';
import 'package:tekno_mistik/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:tekno_mistik/core/utils/content_moderator.dart';
import 'package:tekno_mistik/core/theme/app_text_styles.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  // Seed Content (Bot Posts)
  final List<Map<String, String>> _posts = [];
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadSeedContent();
  }

  void _loadSeedContent() {
    // Uygulama "Ghost Town" gibi görünmesin diye sahte veriler
    _posts.addAll([
      {
        "user": "Gezgin #101",
        "content": "Merkür retrosu beni mahvetti... Elektronik aletlerim isyan ediyor.",
        "tag": "Retro",
        "likes": "42",
        "comments": "12"
      },
      {
        "user": "Gezgin #88",
        "content": "Güneş kartı geldi! Bugün enerjim tavan yaptı, herkese şifa diliyorum.",
        "tag": "Tarot",
        "likes": "128",
        "comments": "34"
      },
      {
        "user": "Gezgin #9931",
        "content": "Schumann rezonansını takip eden var mı? Baş ağrısı yapıyor bugün.",
        "tag": "Frekans",
        "likes": "15",
        "comments": "8"
      },
      {
        "user": "Gezgin #420",
        "content": "Meditasyon sırasında mor bir ışık gördüm. Anlamını bilen var mı?",
        "tag": "Meditasyon",
        "likes": "56",
        "comments": "21"
      },
       {
        "user": "Gezgin #777",
        "content": "Kozmik mağazadaki Kahin paketini aldım, analizler inanılmaz detaylı.",
        "tag": "Deneyim",
        "likes": "89",
        "comments": "5"
      },
    ]);
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
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, 
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
                    Text("EVRENE MESAJ BIRAK", style: AppTextStyles.h3.copyWith(color: Colors.white)),
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
                        if (ContentModerator.isSafe(postController.text)) {
                          _addNewPost(postController.text);
                          Navigator.pop(context);
                        } else {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF1E1E2C),
                              title: Text("Negatif Enerji Tespit Edildi", style: AppTextStyles.h3.copyWith(color: AppTheme.errorRed, fontSize: 16)),
                              content: Text("Mesajın, kozmik topluluk kurallarımıza uymayan kelimeler içeriyor. Lütfen ifadelerini arındır.", style: AppTextStyles.bodyMedium),
                              actions: [
                                TextButton(child: Text("TAMAM", style: TextStyle(color: AppTheme.neonCyan)), onPressed: () => Navigator.pop(ctx)),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    child: Text("SİNYALİ GÖNDER", style: AppTextStyles.button),
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
          padding: const EdgeInsets.only(bottom: 100), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // SECTION 1: ASTROLOGER INSIGHTS
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("YILDIZ REHBERLERİ", style: AppTextStyles.button.copyWith(color: AppTheme.neonCyan, fontSize: 14)),
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
                child: Text("GEZGİN AKIŞI", style: AppTextStyles.button.copyWith(color: AppTheme.neonPurple, fontSize: 14)),
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
        padding: const EdgeInsets.only(bottom: 80.0, right: 10.0), 
        child: FloatingActionButton(
          backgroundColor: Colors.transparent, 
          elevation: 10,
          onPressed: () => _showPostDialog(context),
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
                Text(name, style: AppTextStyles.h3.copyWith(fontSize: 20, color: glowColor)),
                const SizedBox(height: 20),
                Text(
                  dailyMessage,
                  style: AppTextStyles.bodyLarge,
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
                   image: const NetworkImage("https://picsum.photos/100"), 
                   fit: BoxFit.cover
                )
              ),
              child: const Center(child: Icon(Icons.person, color: Colors.white38)), 
            ),
            const SizedBox(height: 8),
            Text(name, style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
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
    isLiked = false; 
    likeCount = widget.initialLikes;
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
        title: Text("Enerji İhlali Bildirimi", style: AppTextStyles.h3.copyWith(color: AppTheme.errorRed, fontSize: 16)),
        content: Text("Bu paylaşım kozmik topluluk kurallarını ihlal mi ediyor? Bildirimin anonim olarak incelenecektir.", style: AppTextStyles.bodyMedium),
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
              height: MediaQuery.of(context).size.height * 0.7, 
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E2C), // Slightly lighter black as requested
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(top: BorderSide(color: Colors.cyanAccent, width: 1))
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text("Yorumlar", style: AppTextStyles.h3),
                  ),
                  const Divider(color: Colors.white10),

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
                          subtitle: Text(comment['text'] ?? '', style: AppTextStyles.bodyMedium),
                        );
                      },
                    ),
                  ),

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
              Row(
                children: [
                  CircleAvatar(radius: 12, backgroundColor: Colors.white24, child: const Icon(Icons.person, size: 14, color: Colors.white)),
                  const SizedBox(width: 8),
                  Text(widget.username, style: AppTextStyles.button.copyWith(color: AppTheme.neonCyan, fontSize: 12)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.neonPurple.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(widget.tag, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.content,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
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
