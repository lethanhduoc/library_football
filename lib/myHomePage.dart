import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:library_player/list_image.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

const baseUrl =
    "https://f994-2001-ee0-55cd-2540-6d49-2c79-1a44-e374.ngrok-free.app";

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _wordsSpoken = "";
  bool search = false;
  String toList = "";
  File? saveImage;
  String fullName = "";
  String birthDay = "";
  String height = "";
  String weight = "";
  String positions = "";
  String nationality = "";
  String age = "";
  final TextEditingController contentController = TextEditingController();
  Uint8List webImage = Uint8List(8);

  Future<void> pickImage() async {
    if (!kIsWeb) {
      final ImagePicker picker0 = ImagePicker();
      XFile? image = await picker0.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          saveImage = selected;
        });
      } else {
        print("No image has been picked");
      }
    } else if (kIsWeb) {
      final ImagePicker picker = ImagePicker();
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          saveImage = File('a');
        });
      } else {
        print("No image has been picked");
      }
    } else {
      print("Something went wrong");
    }
  }

  Future<Map<String, dynamic>> getEmbedding(Uint8List imageBytes) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://127.0.0.1:8000/get_embedding'));

      // Convert Uint8List to List<int>
      List<int> imageList = imageBytes.toList();

      // Add image data to the request
      request.files.add(http.MultipartFile.fromBytes('image', imageList,
          filename: 'image.jpg'));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        return json.decode(responseBody);
      } else {
        // Handle error
        print("Error: ${response.statusCode}");
        return {"error": "Failed to get embedding"};
      }
    } catch (e) {
      // Handle other exceptions
      print("Exception: $e");
      return {"error": "Internal client error"};
    }
  }

  Future<Map<String, dynamic>> callApi(String query) async {
    const url = '$baseUrl/text_embedding/_search?pretty';
    const username = 'elastic';
    const password = 'uvkpu*mJUbM-tUPZfILl';
    const credentials = '$username:$password';
    final basicAuth = base64Encode(utf8.encode(credentials));

    final body = {
      "query": {
        "match": {
          "all_info": {"query": query, "fuzziness": "auto"}
        }
      }
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Basic $basicAuth',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // print(jsonDecode(response.body).toString());
      final responseData = jsonDecode(Utf8Decoder().convert(response.bodyBytes))
          as Map<String, dynamic>;
      final hits = responseData['hits']['hits'] as List<dynamic>;
      if (hits.isNotEmpty) {
        final source = hits[0]['_source'] as Map<String, dynamic>;
        final allInfo = source['all_info'] as String;
        final fullNameResult = source['full_name'] as String;
        final birthDayMatch = RegExp(r'birth_date ([^ ]+)').firstMatch(allInfo);
        final ageMatch = RegExp(r'age ([^ ]+)').firstMatch(allInfo);
        final heightMatch = RegExp(r'height_cm ([^ ]+)').firstMatch(allInfo);
        final weightMatch = RegExp(r'weight_kgs ([^ ]+)').firstMatch(allInfo);
        final positionsMatch = RegExp(r'positions ([^ ]+)').firstMatch(allInfo);
        final nationalityMatch =
            RegExp(r'nationality ([^ ]+)').firstMatch(allInfo);
        if (ageMatch != null &&
            birthDayMatch != null &&
            heightMatch != null &&
            weightMatch != null &&
            positionsMatch != null &&
            nationalityMatch != null) {
          setState(() {
            fullName = fullNameResult;
            age = ageMatch.group(1) ?? "";
            weight = weightMatch.group(1) ?? "";
            height = heightMatch.group(1) ?? "";
            birthDay = birthDayMatch.group(1) ?? "";
            positions = positionsMatch.group(1) ?? "";
            nationality = nationalityMatch.group(1) ?? "";
          });
        } else {
          throw Exception(
              'Lỗi khi gọi API với mã trạng thái: ${response.statusCode}');
        }
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'API call failed with status code: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
    });
  }

  @override
  Widget build(BuildContext context) {
    contentController.toString();
    // final TextEditingController controllerSpeak =
    //     TextEditingController(text: _wordsSpoken);
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(
      padding: EdgeInsets.only(
          top: search || saveImage != null ? 20 : screenSize.height / 3),
      alignment: search == false || saveImage == null
          ? Alignment.center
          : Alignment.topLeft,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/background-bong-da.jpg"),
              fit: BoxFit.cover)),
      child: Column(
        children: [
          search || saveImage != null
              ? Container()
              : Text(
                  "Library Football Player",
                  style: GoogleFonts.playball(
                      fontSize: 45,
                      color: const Color.fromARGB(255, 127, 206, 22)),
                ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: screenSize.width / 3,
            // padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(.1),
                      offset: const Offset(0, 40),
                      blurRadius: 80)
                ]),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: search ? screenSize.width / 4.5 : screenSize.width / 4,
                  padding: const EdgeInsets.only(left: 8),
                  child: _isListening
                      ? Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  _isListening
                                      ? callApi(_wordsSpoken)
                                      : callApi(contentController.text);
                                },
                                icon: Icon(Icons.search)),
                            Text(
                              _wordsSpoken,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        )
                      : TextField(
                          // ignore: unnecessary_null_comparison
                          controller: contentController,
                          decoration: InputDecoration(
                              suffixIconColor:
                                  const Color.fromARGB(255, 6, 233, 97),
                              prefixIcon: IconButton(
                                onPressed: () {
                                  _isListening
                                      ? callApi(_wordsSpoken)
                                      : callApi(contentController.text);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.search),
                              ),
                              hintText: _speechToText.isListening
                                  ? 'Chúng tôi đang lắng nghe...'
                                  : 'Nhập tên cầu thủ mà bạn muốn tìm thông tin...',
                              hintStyle: const TextStyle(fontSize: 14),
                              border: InputBorder.none),
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    search || saveImage != null
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _isListening = false;
                              });
                            },
                            icon: const Icon(Icons.keyboard),
                            color: Colors.lightBlue,
                          )
                        : Container(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isListening = true;
                        });
                        _speechToText.isListening
                            ? _stopListening()
                            : _startListening();
                      },
                      icon: const Icon(
                        Icons.mic_none_outlined,
                        color: Colors.lightBlue,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await pickImage();
                        Map<String, dynamic> result =
                            await getEmbedding(webImage);
                        print(result);
                      },
                      icon: const Icon(Icons.camera_alt_outlined),
                      color: Colors.lightBlue,
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          search || saveImage != null
              ? Container()
              : ElevatedButton(
                  style: ButtonStyle(
                    minimumSize:
                        MaterialStateProperty.all<Size>(const Size(150, 50)),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 43, 191, 232)),
                  ),
                  onPressed: () async {
                    _isListening
                        ? callApi(_wordsSpoken)
                        : callApi(contentController.text);
                    setState(() {
                      search = true;
                    });
                  },
                  child: Text("Tìm kiếm",
                      style: GoogleFonts.sarabun(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))),
          saveImage != null
              ? Row(
                  children: [
                    Container(
                        alignment: Alignment.center,
                        width: screenSize.width / 2,
                        height: screenSize.height - 200,
                        child: kIsWeb
                            ? Image.memory(
                                webImage,
                                fit: BoxFit.contain,
                              )
                            : Image.file(
                                saveImage!,
                                fit: BoxFit.contain,
                              )),
                    Center(
                        child: Text(
                      "Họ và tên: $fullName",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ))
                  ],
                )
              : Container(),
          fullName != ""
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(
                    //     width: screenSize.width / 2,
                    //     child: Image.asset("images/$loadImage.jpg")),
                    Text(
                      "Họ và tên: $fullName",
                      style: GoogleFonts.notoSans(
                          color: Colors.white, fontSize: 25),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Ngày sinh: $birthDay",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Tuổi: $age",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Chiều cao: $height cm",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Cân nặng: $weight kg",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Vị trí thi đấu: $positions",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Quốc gia: $nationality",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                )
              : Container(),
          // IconButton(
          //   onPressed: () {
          //     Navigator.push(
          //         context, MaterialPageRoute(builder: (context) => MyWidget()));
          //   },
          //   icon: Icon(Icons.add),
          //   iconSize: 50,
          // )
        ],
      ),
    ));
  }
}
