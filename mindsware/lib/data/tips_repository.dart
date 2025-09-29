import 'package:flutter/services.dart' show rootBundle;
import '../models/tip_card.dart';


class TipsRepository {
const TipsRepository();


Future<List<TipCardModel>> loadTips() async {
final raw = await rootBundle.loadString('assets/tips.json');
return TipCardModel.listFromJsonString(raw);
}
}