import 'globals.dart';
import 'package:flutter/material.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

    String addDashes(String text) {
  String formattedText = '';
  for (int i = 0; i < text.length; i++) {
    if (i > 0 && i % 4 == 0 && i < 16) {
      formattedText += '-';
    }
    formattedText += text[i];
  }
  return formattedText;
}

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  String code = "";
  Widget? error;
  

  String checksum(String s) {
  var chk = 0x12345678;
  final len = s.length;
  for (var i = 0; i < len; i++) {
    chk += (s.codeUnitAt(i) * (i + 1));
  }

  var fullChecksum = (chk & 0xffffffff).toRadixString(16);
  return fullChecksum.substring(fullChecksum.length-3).toUpperCase();
}

    final TextEditingController _controller = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Topup"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              autocorrect: false,
              textCapitalization: TextCapitalization.characters,
              
                decoration: InputDecoration(
              filled: true,
              prefixIcon: const Icon(Icons.wallet_giftcard_outlined),
              border: const OutlineInputBorder(),
              label: const Text("Topup code"),
              error: error //Use this when the topup codes have a fixed length
              
            ),
            onChanged: (text) { 
            var sanitizedText = text.replaceAll('-', '');
            sanitizedText = sanitizedText.replaceAll(' ', '');
            sanitizedText = sanitizedText.toUpperCase();
            code = sanitizedText;
            if (sanitizedText.length == 16) {
              setState(() {
              error = null;
              });
            }

  _controller.text = widget.addDashes(sanitizedText);
  _controller.selection = TextSelection.collapsed(offset: _controller.text.length);

          if (sanitizedText.length == 16) {
            String first13characters = sanitizedText.substring(0,13);
            String inputtedChecksum = sanitizedText.substring(13,16);

            if (checksum(first13characters)!= inputtedChecksum) {
              setState(() {
                error = Column(
                  children: [
                    const Center(child: Text("This code isn't valid. Check you have entered everything correctly.")),
                    TextButton(child: const Text("What does this mean?"), onPressed: ()=>showDialog(context: context, builder: (context) => AlertDialog(
                      title: const Text("What does this error mean?"),
                      content: const Text("The last 3 digits of your topup code are used to check that the first 13 were entered correctly. The last 3 digits you entered don't match the first 13.\n\nYou should double check the code if you typed it in."),
                      actions: [TextButton(child: const Text("OK"), onPressed: ()=>Navigator.pop(context),)],
                    )),)
                  ],
                );
              });
            }
          }
            },),
          ),
          ElevatedButton(onPressed: ()async{
             if (code.length != 16) {
                  setState(() {
                  error = const Text("Topup codes are 16 characters long");
                  });
                  return;
                } 

                if (error != null) {
                  return;
                }

            try {
            final codeData = await pb.send("/api/shc/topup/getdetails", body: {"data": code.substring(0,13)}, method: "POST");
              final emailData = await pb.collection('users').getOne(pb.authStore.model.id,
              fields: "email"
    );
              if (codeData['redeemed'] == true) {
                throw "This code has already been redeemed";
              }
              if (!context.mounted) return;
            showDialog(
              barrierDismissible: false,
              context: context, builder: (context) => AlertDialog(
              title: Text("Redeem this \$${codeData['value']} code?"),
              content: Text("It will be added to your account (${emailData.data['email']})"),
              actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("Nevermind")),
              TextButton(onPressed: () async {
                try {
                await pb.send("/api/shc/topup/usecode/${pb.authStore.model.id}", method: "POST", body: {"data": code.substring(0,13)});
                if (!context.mounted) return;
                Navigator.pop(context);
                Navigator.pop(context);
                } catch (e) {
                  showDialog(context: context, builder: (context) =>AlertDialog(
                    title: const Text("Something went wrong"),
                    content: Text(e.toString()),
                  ));
                }
              }, child: const Text("Redeem it"),)],
            ));
            } catch (e){
              showDialog(context: context, builder: (context) => AlertDialog(
                title: const Text("Something went wrong"),
                content: Text(e.toString()),
              ));
            }
          }, child: const Text("Topup"))
        ],
      ),
    );
  }
}

