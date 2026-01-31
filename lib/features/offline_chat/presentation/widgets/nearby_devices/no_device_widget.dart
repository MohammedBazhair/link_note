import 'package:flutter/material.dart';

import '../../../../../core/constants/colors/colors.dart';

class NoDevicesWidget extends StatelessWidget {
  const NoDevicesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_searching, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('لا توجد أجهزة قريبة الآن'),
          SizedBox(height: 10),
          Text(
            'تأكد من تفعيل البلوتوث والموقع',
            style: TextStyle(color: DarkColors.secondFont, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
