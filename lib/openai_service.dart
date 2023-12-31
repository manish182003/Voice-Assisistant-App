import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:voice_assistant_app/secrets.dart';

class OpenAiService {
  final List<Map<String, String>> messages = [];
  Future<String> isartpromptapi(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openaiapikey',
        },
        body: jsonEncode(
          {
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                'role': 'user',
                'content':
                    'Does this message want to generate an AI picture,image, art or anything similar? $prompt . Simply answer with yes or no.',
              }
            ],
          },
        ),
      );
      // print(res.body);
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        switch (content) {
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
          case 'YES':
          case 'YES.':
            final res = await dalleAPI(prompt);
            return res;
          case 'No':
          case 'no':
          case 'No.':
          case 'no.':
          case 'NO':
          case 'NO.':
            final res = ChatGPTAPI(prompt);
            return res;
          default:
            final res = ChatGPTAPI(prompt);
            return res;
        }
      }

      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dalleAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openaiapikey',
        },
        body: jsonEncode(
          {
            'prompt': prompt,
            'n': 1,
          },
        ),
      );
      // print(res.body);
      if (res.statusCode == 200) {
        String imageurl = jsonDecode(res.body)['data'][0]['url'];
        imageurl = imageurl.trim();
        messages.add({
          'role': 'assistant',
          'content': imageurl,
        });
        print(imageurl);
        return imageurl;
      }

      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> ChatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openaiapikey',
        },
        body: jsonEncode(
          {
            "model": "gpt-3.5-turbo",
            "messages": messages,
          },
        ),
      );
      print(res.body);
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }

      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }
}
