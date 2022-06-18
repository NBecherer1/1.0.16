import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:na0826/widgets/responsive_safe_area.dart';
import 'package:na0826/widgets/loading_dialog.dart';
import 'package:na0826/core/usecases/usecase.dart';
import 'package:na0826/core/constants/keys.dart';
import '../injection/injection_container.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'loginHelper.dart';



class PrivateUserSignIn extends StatefulWidget {
  const PrivateUserSignIn({Key? key}) : super(key: key);

  @override
  _PrivateUserSignInState createState() => _PrivateUserSignInState();
}

class _PrivateUserSignInState extends State<PrivateUserSignIn> {

  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscureText = true;
  bool _remember = true;
  String domain = '';

  @override
  void initState() {
    var _baseUrl = boxInitApp.get(Keys.baseUrl, defaultValue: '');
    var _username = boxInitApp.get(Keys.username, defaultValue: '');
    var _password = boxInitApp.get(Keys.password, defaultValue: '');
    var hasRemember = boxInitApp.get(Keys.remember, defaultValue: true);
    _baseUrlController.text = _baseUrl??'';
    _usernameController.text = _username??'';
    _passwordController.text = _password??'';
    _remember = hasRemember??true;
    _askForPermissions();
    super.initState();
  }


  Future<String?> _scanQR() async {
    try {
      final barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "cancel".tr, true, ScanMode.DEFAULT);
      if (barcodeScanRes.isNotEmpty && barcodeScanRes != '-1') {
        return barcodeScanRes;
      }
      return null;
    } on PlatformException {
      logger.e('Failed to get platform version.');
      return null;
    }
  }

  Future<void> _askForPermissions() async {
    var cameraStatus = await Permission.camera.status;
    var storageStatus = await Permission.storage.status;
    var notificationStatus = await Permission.notification.status;
    if (cameraStatus.isDenied ||
        storageStatus.isDenied ||
        notificationStatus.isDenied) {
      await [
        Permission.camera,
        Permission.storage,
        Permission.notification,
      ].request();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final node = FocusScope.of(context);
    return ResponsiveSafeArea(
        builder: (BuildContext context) {
          return Scaffold(
            body: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Form(
                    key: formKey,
                    child: AutofillGroup(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logo-transparent-min.webp',
                                width: size.width/2,
                                height: size.width/2,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onDoubleTap: () async {
                                    if (_baseUrlController.text.isEmpty) {
                                      ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
                                      if (cdata != null  && cdata.text != null) {
                                        _baseUrlController.text = cdata.text!;
                                      }
                                    } else {
                                      _baseUrlController.clear();
                                    }
                                  },
                                  child: TextFormField(
                                    // initialValue: baseUrl,
                                    controller: _baseUrlController,
                                    keyboardType: TextInputType.url,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                      labelText: "Server Name",
                                      // labelText: "Base URL",
                                      hintText: "https://domain.com",
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: Image.asset('assets/icon/QR_Icon.png'),
                                        onPressed: () async {
                                          String? val = await _scanQR();
                                          if (val != null) {
                                            _baseUrlController.text = val
                                                .replaceAll('Server Name: ', '');
                                          }
                                        },
                                      ),
                                    ),
                                    textInputAction: TextInputAction.next,
                                    onEditingComplete: () => node.nextFocus(),
                                    validator: (value) {
                                      if (value?.isEmpty == true) {
                                        return "Server Name cannot be empty";
                                      }

                                      // TODO: 11
                                      if (!value!.startsWith("https://")) {
                                        return "URL must start with https://";
                                      }

                                      // if (!value.startsWith("http://") &&
                                      //     !value.startsWith("https://")) {
                                      //   return "URL must start with http:// or https://";
                                      // }
                                      if (value.endsWith("/")) {
                                        return "URL must not include a trailing slash";
                                      }
                                      return null;
                                    },
                                    // onSaved: (newValue) => baseUrl = newValue,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onDoubleTap: () async {
                                          if (_usernameController.text.isEmpty) {
                                            ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
                                            if (cdata != null  && cdata.text != null) {
                                              _usernameController.text = cdata.text!;
                                            }
                                          } else {
                                            _usernameController.clear();
                                          }
                                        },
                                        child: TextFormField(
                                          autocorrect: false,
                                          controller: _usernameController,
                                          keyboardType: TextInputType.visiblePassword,
                                          autofillHints: const [AutofillHints.username],
                                          decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            labelText: "Username",
                                            suffixIcon: IconButton(
                                              icon: Image.asset('assets/icon/QR_Icon.png'),
                                              onPressed: () async {
                                                String? val = await _scanQR();
                                                if (val != null) {
                                                  final startIndex = val.indexOf('\n');
                                                  final user = val.substring(0, startIndex);
                                                  final pass = val.substring(startIndex, val.length);
                                                  _usernameController.text = user.replaceAll('Username: ', '');
                                                  _passwordController.text = pass.replaceAll('Password: ', '');
                                                }
                                              },
                                            ),
                                          ),
                                          textInputAction: TextInputAction.next,
                                          onEditingComplete: () => node.nextFocus(),
                                          validator: (val) {
                                            if(val!.isEmpty) {
                                              return 'required field';
                                            } else {
                                              return null;
                                            }
                                          },
                                          // onSaved: (newValue) => username = newValue,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onDoubleTap: () async {
                                          if (_passwordController.text.isEmpty) {
                                            ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
                                            if (cdata != null  && cdata.text != null) {
                                              _passwordController.text = cdata.text!;
                                            }
                                          } else {
                                            _passwordController.clear();
                                          }
                                        },
                                        child: TextFormField(
                                          autocorrect: false,
                                          obscureText: obscureText,
                                          controller: _passwordController,
                                          keyboardType: TextInputType.visiblePassword,
                                          autofillHints: const [AutofillHints.password],
                                          decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            labelText: "Password",
                                            suffixIcon: IconButton(
                                              icon: Icon(obscureText
                                                  ? Icons.visibility : Icons.visibility_off,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  obscureText = !obscureText;
                                                });
                                              },
                                            ),
                                          ),
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (_) async => await sendForm(),
                                          validator: (val) {
                                            if(val!.isEmpty) {
                                              return 'required field';
                                            } else {
                                              return null;
                                            }
                                          },
                                          // onSaved: (newValue) => password = newValue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              CheckboxListTile(
                                title: const Text('Remember me'),
                                // subtitle: const Text('A computer science portal for geeks.'),
                                secondary: const Icon(Icons.save),
                                autofocus: false,
                                activeColor: Theme.of(context).colorScheme.primary,
                                checkColor: Colors.white,
                                selected: _remember,
                                value: _remember,
                                onChanged: (bool? value) {
                                  if (formKey.currentState?.validate() == true) {
                                    setState(() {
                                      _remember = value??false;
                                    });
                                  }
                                },
                              ),

                              /*
                            Container(
                              alignment: const Alignment(1.0, 0.0),
                              padding: const EdgeInsets.only(top: 15.0, left: 0, right: 8),
                              child: TextButton(
                                child: const Text('clear fields',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                onPressed: () {
                                  _box.delete('baseUrl');
                                  _baseUrlController.clear();
                                  _box.delete('username');
                                  _usernameController.clear();
                                  _passwordController.clear();
                                },
                              ),
                            ),
                             */

                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pushNamed("/logs"),
                                      child: const Text("LOGS"),
                                    ),
                                    ElevatedButton(
                                      child: const Text("LOGIN"),
                                      // onPressed: isAuthenticating ? null : () async => await sendForm(),
                                      onPressed: () async => await sendForm(),
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  Future<void> sendForm() async {
    if (formKey.currentState?.validate() == true) {
      // formKey.currentState!.save();
      LoadingDialog.show(context: context);

      if (_remember) {
        await boxInitApp.put(Keys.remember, _remember);
        await boxInitApp.put(Keys.baseUrl, _baseUrlController.text.trim());
        await boxInitApp.put(Keys.username, _usernameController.text.trim());
        await boxInitApp.put(Keys.password, _passwordController.text.trim());
      } else {

        if (boxInitApp.containsKey(Keys.baseUrl)) {
          await boxInitApp.delete(Keys.baseUrl);
        }

        if (boxInitApp.containsKey(Keys.username)) {
          await boxInitApp.delete(Keys.username);
        }

        if (boxInitApp.containsKey(Keys.password)) {
          await boxInitApp.delete(Keys.password);
        }

        if (boxInitApp.containsKey(Keys.remember)) {
          await boxInitApp.delete(Keys.remember);
        }

      }

      await loginHelper(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        baseUrl: _baseUrlController.text.trim(),
        context: context,
      );
    }
  }
}
