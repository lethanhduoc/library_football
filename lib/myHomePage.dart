import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

const baseUrl = "https://db80-14-191-231-51.ngrok-free.app";
const baseUrlImage = "https://9144-14-161-13-116.ngrok-free.app";

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SpeechToText _speechToText = SpeechToText();
  List<Map<String, dynamic>> searchResults = [];
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
  int lengthHits = 0;
  final TextEditingController contentController = TextEditingController();
  Uint8List webImage = Uint8List(8);
  String loadImage = "";
  String pathImage = "";
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
    const password = 'adRrlsplh+MxJkHATFKI';
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
      final responseData =
          jsonDecode(const Utf8Decoder().convert(response.bodyBytes))
              as Map<String, dynamic>;
      final hits = responseData['hits']['hits'] as List<dynamic>;
      if (hits.isNotEmpty) {
        for (var i = 0; i < hits.length; i++) {
          final source = hits[i]['_source'] as Map<String, dynamic>;
          final allInfo = source['all_info'] as String;
          final fullNameResult = source['full_name'] as String;
          final birthDayMatch =
              RegExp(r'birth_date ([^ ]+)').firstMatch(allInfo);
          final ageMatch = RegExp(r'age ([^ ]+)').firstMatch(allInfo);
          final heightMatch = RegExp(r'height_cm ([^ ]+)').firstMatch(allInfo);
          final weightMatch = RegExp(r'weight_kgs ([^ ]+)').firstMatch(allInfo);
          final positionsMatch =
              RegExp(r'positions ([^ ]+)').firstMatch(allInfo);
          final nationalityMatch =
              RegExp(r'nationality ([^ ]+)').firstMatch(allInfo);
          if (ageMatch != null &&
              birthDayMatch != null &&
              heightMatch != null &&
              weightMatch != null &&
              positionsMatch != null &&
              nationalityMatch != null) {
            setState(() {
              lengthHits = hits.length;
              fullName = fullNameResult;
              age = ageMatch.group(1) ?? "";
              weight = weightMatch.group(1) ?? "";
              height = heightMatch.group(1) ?? "";
              birthDay = birthDayMatch.group(1) ?? "";
              positions = positionsMatch.group(1) ?? "";
              nationality = nationalityMatch.group(1) ?? "";
              searchResults.add({
                'fullName': fullNameResult,
                'birthDay': birthDayMatch.group(1),
                'age': ageMatch.group(1),
                'height': heightMatch.group(1),
                'weight': weightMatch.group(1),
                'positions': positionsMatch.group(1),
                'nationality': nationalityMatch.group(1),
              });
              print(fullName);
            });
          } else {
            throw Exception(
                'Lỗi khi gọi API với mã trạng thái: ${response.statusCode}');
          }
        }
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'API call failed with status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> callApiImage(String query) async {
    const url = '$baseUrl/text_embedding/_search?pretty';
    const username = 'elastic';
    const password = 'WtiGjp41tsJ5DZuCh7xh';
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
      final responseData =
          jsonDecode(const Utf8Decoder().convert(response.bodyBytes))
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
            lengthHits = hits.length;
            fullName = fullNameResult;
            age = ageMatch.group(1) ?? "";
            weight = weightMatch.group(1) ?? "";
            height = heightMatch.group(1) ?? "";
            birthDay = birthDayMatch.group(1) ?? "";
            positions = positionsMatch.group(1) ?? "";
            nationality = nationalityMatch.group(1) ?? "";
            searchResults.add({
              'fullName': fullNameResult,
              'birthDay': birthDayMatch.group(1),
              'age': ageMatch.group(1),
              'height': heightMatch.group(1),
              'weight': weightMatch.group(1),
              'positions': positionsMatch.group(1),
              'nationality': nationalityMatch.group(1),
            });
            print(fullName);
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

  Future<String> getPlayerName(List<dynamic> queryVector) async {
    try {
      final String apiUrl =
          "https://adb0-2001-ee0-55cd-2540-bd65-2ef4-8158-82cc.ngrok-free.app/image_embedding/_search?pretty";

      final Map<String, dynamic> requestBody = {
        "knn": {
          "field": "image_embedding",
          "query_vector": queryVector,
          "k": 3,
          "num_candidates": 6849
        },
        "fields": ["image_name"]
      };

      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic " +
              base64Encode(utf8.encode("elastic:WtiGjp41tsJ5DZuCh7xh")),
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        // Parse JSON response to get the player name
        Map<String, dynamic> responseData = json.decode(response.body);

        // Check if the expected data is present
        if (responseData.containsKey('hits') &&
            responseData['hits'].containsKey('hits') &&
            responseData['hits']['hits'].isNotEmpty &&
            responseData['hits']['hits'][0].containsKey('fields') &&
            responseData['hits']['hits'][0]['fields']
                .containsKey('image_name')) {
          // Get the player name
          List<dynamic> playerName =
              responseData['hits']['hits'][0]['fields']['image_name'];
          // print(playerName[0]);

          return playerName[0].toString();
        } else {
          // Handle the case when the expected data is not present
          print('Error: Invalid response format');
          return 'Error';
        }
      } else {
        // Handle errors if needed
        print('Error: ${response.statusCode}');
        return 'Error';
      }
    } catch (e) {
      // Handle other exceptions
      print('Exception: $e');
      return 'Error';
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

  Widget showInfor() {
    return Container(
      alignment: Alignment.center,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: searchResults.length,
        itemBuilder: (BuildContext context, int index) {
          final result = searchResults[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Họ và tên: ${result['fullName']}",
                style: GoogleFonts.notoSans(
                    color: Color.fromARGB(255, 174, 221, 36), fontSize: 25),
              ),
              Text(
                "Ngày sinh: ${result['birthDay']}",
                style: GoogleFonts.notoSans(
                    color: Color.fromARGB(255, 242, 237, 237), fontSize: 25),
              ),
              Text(
                "Tuổi: ${result['age']}",
                style: GoogleFonts.notoSans(
                    color: Color.fromARGB(255, 242, 237, 237), fontSize: 25),
              ),
              Text(
                "Cân nặng: ${result['weight']} kg",
                style: GoogleFonts.notoSans(
                    color: Color.fromARGB(255, 242, 237, 237), fontSize: 25),
              ),
              Text(
                "Chiều cao: ${result['height']}",
                style: GoogleFonts.notoSans(
                    color: Color.fromARGB(255, 242, 237, 237), fontSize: 25),
              ),
              Text(
                "Vị trí: ${result['positions']}",
                style: GoogleFonts.notoSans(
                    color: Color.fromARGB(255, 242, 237, 237), fontSize: 25),
              ),
              Text(
                "Quốc gia: ${result['nationality']}",
                style: GoogleFonts.notoSans(
                    color: Color.fromARGB(255, 242, 237, 237), fontSize: 25),
              ),
              SizedBox(
                height: 50,
              )
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final TextEditingController controllerSpeak =
    //     TextEditingController(text: _wordsSpoken);
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        height: search == false ? screenSize.height : null,
        padding: EdgeInsets.only(
            top: search || saveImage != null ? 20 : screenSize.height / 3),
        alignment: search == false || saveImage == null
            ? Alignment.center
            : Alignment.topLeft,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  "images/background-bong-da.jpg",
                ),
                fit: BoxFit.fill)),
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
                    width:
                        search ? screenSize.width / 4.5 : screenSize.width / 4,
                    padding: const EdgeInsets.only(left: 8),
                    child: _isListening
                        ? Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _isListening
                                        ? callApi(_wordsSpoken)
                                        : callApi(contentController.text);
                                    setState(() {
                                      // loadImage = contentController.text;
                                      pathImage = "images/$fullName.jpg";
                                    });
                                  },
                                  icon: const Icon(Icons.search)),
                              Text(
                                _wordsSpoken,
                                style: const TextStyle(fontSize: 14),
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
                                    setState(() {
                                      // loadImage = contentController.text;
                                      pathImage = "images/$fullName.jpg";
                                    });
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

                          List<double> embeddingValues =
                              List<double>.from(result["embedding"]);
                          final imageName =
                              await getPlayerName(embeddingValues);
                          String modifiedText = imageName.replaceAll('_', ' ');
                          print(modifiedText);
                          setState(() {
                            callApiImage(modifiedText);
                          });
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
                          const Color.fromARGB(255, 43, 191, 232)),
                    ),
                    onPressed: () async {
                      _isListening
                          ? callApi(_wordsSpoken)
                          : callApi(contentController.text);
                      setState(() {
                        loadImage = contentController.text;
                        search = true;
                        pathImage = "images/$loadImage.jpg";
                        // print(pathImage);
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
                      const SizedBox(
                        width: 15,
                      ),
                      Container(
                          alignment: Alignment.centerRight,
                          width: screenSize.width / 3,
                          child: Center(
                              child: Column(
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Tuổi: $age",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Chiều cao: $height cm",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Cân nặng: $weight kg",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Vị trí thi đấu: $positions",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Quốc gia: $nationality",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ],
                          )))
                    ],
                  )
                : Container(),
            fullName != "" && saveImage == null
                ?
                // ? Row(
                //     children: [
                //       // SizedBox(
                //       //   width: screenSize.width / 2,
                //       //   height: screenSize.height - 200,
                //       //   child: Image.asset(
                //       //     pathImage,
                //       //     fit: BoxFit.cover,
                //       //   ),
                //       // ),
                //       const SizedBox(
                //         width: 15,
                //       ),

                //     ],
                //   )
                Padding(
                    padding:
                        EdgeInsets.only(left: screenSize.width / 3, top: 50),
                    child: Center(child: showInfor()),
                  )
                : Container(),
          ],
        ),
      ),
    ));
  }
}
