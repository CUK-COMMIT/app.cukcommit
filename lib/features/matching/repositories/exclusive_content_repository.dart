import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/exclusive_content.dart';

class ExclusiveContentRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ExclusiveContent>> getExclusiveContent() async {
    final res = await _client
        .from("exclusive_content")
        .select('''
          id,
          title,
          description,
          image_url,
          content,
          publish_date,
          tags,
          required_months
        ''')
        .order("publish_date", ascending: false);

    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map(ExclusiveContent.fromSupabase).toList();
  }
}
