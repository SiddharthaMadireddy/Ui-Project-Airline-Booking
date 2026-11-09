import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/notice_provider.dart';

/// Dismissible travel advisory ticker displayed directly below top navigation
class NoticeTicker extends StatelessWidget {
  const NoticeTicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoticeProvider>(
      builder: (context, noticeProvider, child) {
        final notice = noticeProvider.currentNotice;
        if (notice == null || noticeProvider.isDismissed) {
          return const SizedBox.shrink();
        }

        final isAdvisory = notice.type == 'advisory';
        final isPromo = notice.type == 'promo';

        final Color bgColor = isAdvisory
            ? const Color(0xFFFFFBEB)
            : (isPromo ? const Color(0xFFEFF6FF) : const Color(0xFFF3F4F6));
        final Color textColor = isAdvisory
            ? const Color(0xFF92400E)
            : (isPromo ? const Color(0xFF1E40AF) : const Color(0xFF1F2937));
        final Color iconColor = isAdvisory
            ? const Color(0xFFD97706)
            : (isPromo ? AppConstants.primaryNavy : const Color(0xFF4B5563));

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              bottom: BorderSide(
                color: isAdvisory
                    ? const Color(0xFFFDE68A)
                    : const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(
                isAdvisory
                    ? Icons.warning_amber_rounded
                    : (isPromo ? Icons.campaign_outlined : Icons.info_outline),
                color: iconColor,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  notice.message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => noticeProvider.nextNotice(),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios, size: 10, color: textColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => noticeProvider.dismiss(),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.close, size: 16, color: textColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
