class ContentModerator {
  // YASAKLI KELİME LİSTESİ
  // Not: Tam liste entegrasyonu için buraya ekleme yapılabilir.
  static const List<String> _forbiddenWords = [
    "abaza", "abazan", "ag", "ağzına sıçayım", "ahmak", "allahsız", 
    "am", "amarım", "ambiti", "amcı", "amcık", "amcığını", "amına", 
    "amına koyayım", "aminako", "aminakoyarim", "amina", "amk", "amq", 
    "anan", "ananı", "ananı sikeyim", "anneni", "anneni sikeyim", "aptal", 
    "aq", "as", "at yarrağı", "avrat", "ayı", "bağırsak", "bombok", "bok", 
    "boktan", "boşluk", "boynuz", "bozdurma", "b.k", "çük", "dalyarak", 
    "daşşak", "döl", "döllü", "düdük", "edin", "fak", "fahişe", "gavat", 
    "gavur", "gerizekalı", "gerzek", "göt", "göte", "götü", "götveren", 
    "götveren", "guat", "haspa", "hassiktir", "has siktir", "haysiyetsiz", 
    "hayvan", "hıyar", "ibne", "ibneler", "ipne", "it", "itoğluit", "kaltak", 
    "kahpe", "kaka", "kancık", "kıç", "kıro", "kerhane", "kevaşe", "kavat", 
    "koduğum", "kodumun", "koyayım", "koyim", "kuniz", "kürtaj", "mal", "manyak", 
    "memeler", "meme", "memiş", "meze", "naş", "oç", "oc", "o.ç", "oğlan", 
    "oğlancı", "orosbu", "orospu", "otuzbir", "31", "öküz", "penis", "piç", 
    "poça", "porn", "porno", "puşt", "pust", "sakso", "salak", "sana sokarım", 
    "sapık", "sersem", "sex", "sıçarım", "sıçmak", "sıçtığım", "sik", "siken", 
    "sikerim", "siki", "sikim", "sikilmiş", "sikiş", "sikişme", "siktim", "siktiğimin", 
    "sokayım", "sokarım", "sokuk", "sürtük", "sürtü", "taşak", "taşşak", "tiki", 
    "tohum", "top", "toto", "vajina", "yarak", "yarrak", "yara", "yavşak", 
    "yerim", "yosma", "zıkkım", "zibidi", "zigsin", "zviyetini"
  ];

  static bool isSafe(String text) {
    // 1. Normalizasyon (Türkçe karakterleri İngilizceye çevir ki "kötü"yü "kotu" olarak da yakalasın)
    String normalizedText = text.toLowerCase()
        .replaceAll('ş', 's')
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');

    for (var word in _forbiddenWords) {
      // Kelimeyi de normalize et (Listede Türkçe karakter varsa diye)
      String normalizedWord = word.toLowerCase()
          .replaceAll('ş', 's')
          .replaceAll('ı', 'i')
          .replaceAll('ğ', 'g')
          .replaceAll('ü', 'u')
          .replaceAll('ö', 'o')
          .replaceAll('ç', 'c');

      // 2. AKILLI KONTROL (Regex)
      // \b : Kelime sınırı demektir. (Sadece tam kelime eşleşmesi arar)
      // Örnek: "am" kelimesi "selam" içinde bulunmaz, çünkü 'm'den sonra sınır yok.
      // Ama "şu am..." cümlesinde bulunur.
      
      try {
        // Kelimenin içinde özel regex karakterleri varsa escape et
        String pattern = r'\b' + RegExp.escape(normalizedWord) + r'\b';
        
        if (RegExp(pattern, caseSensitive: false).hasMatch(normalizedText)) {
          // Eşleşme bulundu (Yasaklı kelime tam olarak geçiyor)
          return false; 
        }
      } catch (e) {
        // Regex hatası olursa (listede bozuk karakter varsa) güvenli varsayma, devam et
        continue;
      }
    }
    return true; // Temiz
  }
}
