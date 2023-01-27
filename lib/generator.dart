import 'package:flutter/material.dart';
import 'package:hmac_sha256/hmac.sha256.dart';

class Generator extends StatefulWidget {
  const Generator({super.key});

  @override
  State<Generator> createState() => _MyGeneratorState();
}

class _MyGeneratorState extends State<Generator> {
  final formKey = GlobalKey<FormState>();
  TextEditingController msgController = TextEditingController();
  TextEditingController keyController = TextEditingController();
  TextEditingController resController = TextEditingController();

  @override
  Flexible build(BuildContext context) {
    return Flexible(
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
                      resController.text = HmacSha256().generate(
                        msgController.text,
                        keyController.text,
                      ),
                    },
                    child: const Text('Compute Hash'),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: resController,
                    // initialValue: "",
                    decoration: const InputDecoration(
                      hintText: "",
                      labelText: "Hash Result",
                      icon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                    maxLines: null,
                    readOnly: true,
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
