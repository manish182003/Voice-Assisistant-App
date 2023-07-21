import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant_app/features_box.dart';
import 'package:voice_assistant_app/openai_service.dart';
import 'package:voice_assistant_app/pallete.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  final speechtotext = SpeechToText();
  String lastWords = '';
  int start = 200;
  int delay = 200;
  final OpenAiService openAiService = OpenAiService();
  final flutterTts = FlutterTts();
  String? generatedcontent;
  String? generatedimageurl;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    inittexttospeech();
  }

  Future<void> inittexttospeech() async {
    //  await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechtotext.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechtotext.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechtotext.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemspeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechtotext.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text('Voice Assistant App'),
        ),
        centerTitle: true,
        leading: const Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            //virtual assistant picture
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                          color: Pallete.assistantCircleColor,
                          shape: BoxShape.circle),
                    ),
                  ),
                  Container(
                    height: 125,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image:
                            AssetImage('assests/images/virtualAssistant.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //chat bubble

            FadeInRight(
              child: Visibility(
                visible: generatedimageurl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40,
                  ).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        generatedcontent == null
                            ? 'Good Morning, what task can I do for you?'
                            : generatedcontent!,
                        style: TextStyle(
                          fontFamily: 'Cera Pro',
                          color: Pallete.mainFontColor,
                          fontSize: generatedcontent == null ? 23 : 18,
                        ),
                      )),
                ),
              ),
            ),
            if (generatedimageurl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  
                  child: Image.network(generatedimageurl!),
                ),
              ),

            SlideInLeft(
              child: Visibility(
                visible: generatedcontent == null && generatedimageurl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(
                    top: 10,
                    left: 22,
                  ),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Here are a few features',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            //features list

            Visibility(
              visible: generatedcontent == null && generatedimageurl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: featurebox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'ChatGPT',
                      descriptiontext:
                          'A smarter way to stay organized and informed with ChatGPT',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: featurebox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptiontext:
                          'Get inspired and stay creative with your personal aassistant powered by Dall-E',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2 * delay),
                    child: featurebox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptiontext:
                          'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if (await speechtotext.hasPermission &&
                speechtotext.isNotListening) {
              flutterTts.stop();
              await startListening();
            } else if (speechtotext.isListening) {
              final speech = await openAiService.isartpromptapi(lastWords);
              if (speech.contains('https')) {
                generatedimageurl = speech;
                generatedcontent = null;
                setState(() {});
              } else {
                generatedimageurl = null;
                generatedcontent = speech;
                setState(() {});
                await systemspeak(speech);
              }

              await stopListening();
            } else {
              initSpeechToText();
            }
          },
          child: Icon(speechtotext.isListening ? Icons.stop : Icons.mic),
        ),
      ),
    );
  }
}
