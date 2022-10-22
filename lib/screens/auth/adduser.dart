import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../homescreen/switchscreen.dart';

class AddUser extends StatefulWidget {
  const AddUser({Key? key}) : super(key: key);

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool session = false;
  bool isLoad = false;
  List UserData = [];
  bool _isObscure = true;

  void loginUser(String email, String password, bool storesession) async {
    setState(() {
      isLoad = true;
    });
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      if (RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(email)) {
        final response = await http.post(
          Uri.parse('${Constants.weblink}' + Routes.LOGIN),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'password': password,
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          var data = jsonDecode(response.body);

          if (data['message'] == "Bad creds") {
            Constants.showtoast("Invalid Email or Password!");
            setState(() {
              isLoad = false;
            });
          } else {
            if (storesession == true) {
              int userid = data['user']['id'];
              String token = data['token'];
              String name = data['user']['firstname'];
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt('userid', userid);
              prefs.setString('token', token);
              prefs.setString('name', name);
              prefs.getString("UserList");

              if (prefs.getString("UserList") == null) {
                prefs.setString("UserList",
                    jsonEncode([{"UserID": "$userid", "token": token, "name": name}]));
              } else {
                String? data = prefs.getString("UserList");
                List DecodeUser = jsonDecode(data!);
                DecodeUser.add({"UserID": "$userid", "token": token, "name": name});
                prefs.setString("UserList", jsonEncode(DecodeUser));
              }
            } else {
              String token = data['token'];
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('token', token);

            }
            setState(() {
              isLoad = false;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Switcher(values: 0)));
              Constants.showtoast("User Added");
            });
          }
        } else {
          setState(() {
            isLoad = false;
          });
          Constants.showtoast("Invalid Email or Password!");
        }
      } else {
        setState(() {
          isLoad = false;
        });
        Constants.showtoast("Email Format is valid!, Please Check");
      }
    } else {
      setState(() {
        isLoad = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Constants.primaryColor,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "WELCOME",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 55,
                        fontFamily: Constants.popinsbold,
                      ),
                    ),
                    Text(
                      "to online reading monitor",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: Constants.popins),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 18,
                            ),
                            Text(
                              " innovations",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: Constants.popins),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 18,
                            ),
                            Text(
                              " automations",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: Constants.popins),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 18,
                            ),
                            Text(
                              " software solutions",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: Constants.popins),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60))),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 15, right: 30, left: 30, bottom: 30),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Image.asset(
                              "assets/images/RmLogo.png",
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 20.0, right: 20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      " Email",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: Constants.popins),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                SizedBox(
                                  height: 60,
                                  child: TextFormField(
                                    controller: _email,
                                    validator: (value) => value!.isEmpty
                                        ? 'Email cannot be blank'
                                        : null,
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(8),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                        ),
                                        filled: false,
                                        // hintStyle: TextStyle(color: Colors.grey[800]),
                                        hintText: "  Enter your Email",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      " Password",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: Constants.popins),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                SizedBox(
                                  height: 60,
                                  child: TextFormField(
                                    controller: _password,
                                    validator: (value) => value!.isEmpty
                                        ? 'Password cannot be blank'
                                        : null,
                                    obscureText: _isObscure,
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                    ),
                                    decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isObscure ? Icons.visibility : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isObscure = !_isObscure;
                                            });
                                          },
                                        ),
                                        contentPadding: const EdgeInsets.all(8),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                        ),
                                        filled: false,
                                        hintText: "  Password",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    shape: const RoundedRectangleBorder(),
                                    activeColor: Constants.primaryColor,
                                    value: session,
                                    onChanged: (value) {
                                      setState(() {
                                        this.session = value!;
                                      });
                                    },
                                  ),
                                  const Text(
                                    "Remember me",
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            height: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              onPressed: () {
                                loginUser(_email.text, _password.text, session);
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      // side: BorderSide(color: Colors.red)
                                    )),
                                backgroundColor: MaterialStateProperty.all(
                                    Constants.secondaryColor),
                              ),
                              child: Center(
                                child: (isLoad == false)
                                    ? Text(
                                  "Sign In",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontFamily: Constants.popins,
                                      fontWeight: FontWeight.bold),
                                )
                                    : const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
