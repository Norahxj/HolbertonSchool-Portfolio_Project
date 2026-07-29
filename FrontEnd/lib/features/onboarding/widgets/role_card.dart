import 'package:flutter/material.dart';

class RoleCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final bool isArabic;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.isArabic,
    required this.onTap,
  });

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SizedBox(
        width: screenWidth * 0.75,
        height: 170,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) {
            setState(() {
              _isHovered = true;
            });
          },
          onExit: (_) {
            setState(() {
              _isHovered = false;
            });
          },
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(28),
              hoverColor: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        textDirection: widget.isArabic
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(
                                top: 3,
                                bottom: 3,
                                end: 6,
                              ),
                              child: Image.asset(
                                widget.imagePath,
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                errorBuilder: (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Directionality(
                              textDirection: widget.isArabic
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: widget.isArabic
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    textAlign: widget.isArabic
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    style: const TextStyle(
                                      color: Color(0xFF7047C7),
                                      fontSize: 23,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.description,
                                    textAlign: widget.isArabic
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF676174),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Transform.translate(
                            offset: const Offset(0, 4),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF7047C7),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF7047C7,
                                    ).withOpacity(0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Transform.flip(
                                flipX: widget.isArabic,
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 27,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // طبقة الـ Hover فوق جميع محتويات الكرت.
                    IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: _isHovered
                              ? Colors.black.withOpacity(0.055)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}