import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({Key? key}) : super(key: key);

  Widget getListTile(String vendorName, String logoSvgPath, String url, String qrPostfix) {
    return ListTile(
      title: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: SvgPicture.asset(
            "assets/$logoSvgPath.svg",
            height: Get.textTheme.displayMedium!.fontSize!,
            semanticsLabel: "$vendorName Button",
          ),
        ),
        onPressed: () async {
          if (await canLaunchUrlString(url)) {
            try {
              launchUrlString(url);
            } catch (e) {
              debugPrint("Error: $e");
            }
          }
        },
      ),
      subtitle: ElevatedButton.icon(
        icon: Icon(Icons.qr_code_scanner, size: Get.textTheme.displayLarge!.fontSize!),
        label: const Text("Display QR"),
        onPressed: () {
          Get.bottomSheet(
            backgroundColor: Colors.white,
            Column(
              children: [
                const SizedBox(width: 40, height: 40),
                SvgPicture.asset(
                  "assets/$logoSvgPath.svg",
                  height: Get.textTheme.displayMedium!.fontSize!,
                  semanticsLabel: "$vendorName Button",
                ),
                Expanded(
                  child: Center(
                    child: QrImage(
                      data: "$url$qrPostfix",
                      version: QrVersions.auto,
                      size: min(Get.mediaQuery.size.width, Get.mediaQuery.size.height) * 2 / 3,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donation"),
      ),
      body: ListView(
        children: [
          getListTile(
            "PayPal",
            "paypal-color",
            "https://www.paypal.com/donate/?business=5RV59VYDBAL52&no_recurring=0&item_name=Free+open+source+software&currency_code=USD",
            "&source=qr",
          ),
          getListTile("Buy Me A Coffee", "bmc-button", "https://www.buymeacoffee.com/tocsa", ""),
          getListTile(
            "Ko-fi",
            "kofi-button-blue",
            "https://Ko-fi.com/tocsa",
            "https://ko-fi.com/Y8Y6GZF9A/?ref=qr",
          ),
          getListTile(
            "Venmo",
            "venmo-logo",
            "https://venmo.com/code?user_id=2114670181744640341&created=1670822626",
            "&printed=true",
          ),
          getListTile(
            "CashApp",
            "cash-app",
            "https://cash.app/\$CsabaToth",
            "?qr=1",
          ),
          getListTile(
            "Zelle",
            "zelle-logo",
            "https://enroll.zellepay.com/qr-codes?data=eyJuYW1lIjoiQ1NBQkEiLCJhY3Rpb24iOiJwYXltZW50IiwidG9rZW4iOiJjc2FiYS50b3RoLnVzQG91dGxvb2suY29tIn0=",
            "",
          ),
        ],
      ),
    );
  }
}
