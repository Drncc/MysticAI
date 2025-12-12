import 'dart:math';

class TarotCard {
  final int id;
  final String codeName; // Dosya ismi referansı (Örn: 'fool', 'theempress')
  final String nameTr;   // Ekranda görünecek isim (Örn: 'Deli', 'İmparatoriçe')
  final int variantCount;
  final String meaning;
  
  // Eski 'name' parametresini 'nameTr' ile değiştiriyoruz veya 'name' getter'ı ekliyoruz uyumluluk için.
  // Projenin geri kalanında .name kullanılıyorsa getter kullanmak mantıklı.
  String get name => nameTr;

  TarotCard({
    required this.id,
    required this.codeName,
    required this.nameTr,
    this.variantCount = 3,
    this.meaning = '',
  });

  // Getter: Rastgele Resim Yolu Oluşturucu
  // Dosya formatı: assets/tarot/{id}_{codeName}_{variant}.jpg
  String get randomImagePath {
    final randomVariant = Random().nextInt(variantCount) + 1; 
    return 'assets/tarot/${id}_${codeName}_$randomVariant.jpg';
  }
}
