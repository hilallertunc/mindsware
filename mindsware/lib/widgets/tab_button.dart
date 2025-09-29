import 'package:flutter/material.dart';

class TabButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelect;
  final VoidCallback onPressed;

  const TabButton(
      {super.key,
      required this.icon,
      required this.title,
      required this.isSelect,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: isSelect ? Colors.grey : Colors.transparent,
                  borderRadius: BorderRadius.circular(15)),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 22,
                color: isSelect ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              title,
              style: TextStyle(
                color: isSelect ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ));
  }
}