import 'package:flutter/material.dart';
import 'package:hmac_sha256/hmac.sha256.dart';

class Validator extends StatefulWidget {
  const Validator({super.key});

  @override
  State<Validator> createState() => _MyValidatorState();
}

class _MyValidatorState extends State<Validator> {
  final formKey = GlobalKey<FormState>();
  TextEditingController msgController = TextEditingController();
  TextEditingController hashController = TextEditingController();
  TextEditingController keyController = TextEditingController();
  int valid = -1;

  @override
  Expanded build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Form(
            key: formKey,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: msgController,
                    decoration: const InputDecoration(
                      hintText: "",
                      labelText: "Enter Plain Text",
                      icon: Icon(Icons.text_fields),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                    maxLines: null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: hashController,
                    decoration: const InputDecoration(
                      hintText: "",
                      labelText: "Enter Hash",
                      icon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                    maxLines: null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: keyController,
                    decoration: const InputDecoration(
                      hintText: "",
                      labelText: "Enter the Secret Key",
                      icon: Icon(Icons.key),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                    maxLines: null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => {
                      if (msgController.text == "")
                        {
                          valid = -1,
                        }
                      else if (HmacSha256().validate(
                        msgController.text,
                        keyController.text,
                        hashController.text,
                      ))
                        {
                          valid = 1,
                        }
                      else
                        {
                          valid = 0,
                        },
                      debugPrint('valid: $valid'),
                      setState(() {
                        valid = valid;
                      }),
                    },
                    child: const Text('Validate'),
                  ),
                  const SizedBox(height: 20),
                  Visibility(
                    visible: valid == 1,
                    child: TextFormField(
                      initialValue: "Valid",
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        icon: Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                      ),
                      maxLines: null,
                      readOnly: true,
                    ),
                  ),
                  Visibility(
                    visible: valid == 0,
                    child: TextFormField(
                      initialValue: "Invalid",
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        icon: Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                      ),
                      maxLines: null,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
