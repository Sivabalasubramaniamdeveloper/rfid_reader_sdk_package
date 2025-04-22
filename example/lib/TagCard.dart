import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TagCard extends StatefulWidget {
  final String tagId;
  final String lastUpdate;
  final double distance;
  final int count;
  final bool? isSelected;
  final VoidCallback onTap;

  const TagCard({
    super.key,
    required this.tagId,
    required this.lastUpdate,
    required this.distance,
    required this.count,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<TagCard> createState() => _TagCardState();
}

class _TagCardState extends State<TagCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16).r,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6).r,
        child: Padding(
          padding: const EdgeInsets.all(14).r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sensors,
                    color: Colors.deepPurple,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      widget.tagId,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
              Divider(height: 16.h, color: Colors.grey.shade300),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoTile(Icons.update, "Last Scanned", widget.lastUpdate),
                  // _infoTile(Icons.speed, "Distance",
                  //     !widget.isSelected! ?"0":  "${widget.distance.toStringAsFixed(1)} cm"),
                  // _infoTile(Icons.countertops, "Count", "${widget.count}"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
