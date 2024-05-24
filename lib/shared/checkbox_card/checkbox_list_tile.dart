import 'package:flutter/material.dart';
import 'package:sp_tastebud/core/themes/app_palette.dart';
import 'custom_checkbox_icon.dart';

class CustomCheckboxListTile extends StatefulWidget {
  const CustomCheckboxListTile({
    super.key,
    required this.title,
    required this.valueNotifier,
    this.infoText,
    this.onChanged,
    required this.type,
    required this.index,
  });

  final String title;
  final ValueNotifier<bool> valueNotifier;
  final String? infoText;
  final ValueChanged<bool>? onChanged;
  final String type;
  final int index;

  @override
  State<CustomCheckboxListTile> createState() => _CustomCheckboxListTileState();
}

class _CustomCheckboxListTileState extends State<CustomCheckboxListTile> {
  @override
  void initState() {
    super.initState();
  }

  void _onChanged(bool? newValue) {
    if (newValue != null) {
      widget.valueNotifier.value = newValue;
      widget.onChanged?.call(newValue);
    }
  }

  void _showInfoDialog(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        title: Text(widget.title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            )),
        content: SizedBox(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.valueNotifier,
      builder: (context, value, child) {
        return Row(
          children: [
            IconCheckbox(
              valueNotifier: widget.valueNotifier,
              title: widget.title,
              type: widget.type,
              index: widget.index,
              onChanged: _onChanged,
            ),
            Expanded(
                child: Row(
              children: [
                widget.infoText != null
                    ? GestureDetector(
                        onTap: () => _showInfoDialog(widget.infoText!),
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: widget.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter',
                                color: Colors.black87,
                              ),
                            ),
                            TextSpan(
                                text: '*',
                                style: TextStyle(
                                    fontSize: 18, color: AppColors.redColor))
                          ]),
                        ),
                      )

                    // info text parameter is null, display as normal text
                    : Text(
                        widget.title,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
              ],
            )),
          ],
        );
      },
    );
  }
}
