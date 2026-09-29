import 'package:flutter/material.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/finzo_book_tokens.dart';

/// Карточка урока как у дизайнера («Книжка 2 стр.svg»).
///
/// Компактная tinted-карточка с тонкой рамкой, заголовком, body
/// и круговым номером, частично выходящим за верхний край.
class BookLessonCard extends StatelessWidget {
  const BookLessonCard({
    super.key,
    required this.number,
    required this.tone,
    required this.title,
    required this.text,
    this.illustration,
    this.height,
  });

  final int number;
  final BookCardTone tone;
  final String title;
  final String text;
  final Widget? illustration;

  /// Если null — высота из токенов × contentScale.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final s = FinzoBookTokens.contentScale;
    final h = height ?? FinzoBookTokens.cardHeight * s;
    final r = FinzoBookTokens.cardRadius * s;
    final badgeR = FinzoBookTokens.badgeRadius * s;
    final overflow = FinzoBookTokens.badgeOverflow * s;
    final fill = FinzoBookTokens.fillFor(tone);
    final stroke = FinzoBookTokens.strokeFor(tone);
    final badge = FinzoBookTokens.badgeFor(tone);
    final titleColor = tone == BookCardTone.danger
        ? FinzoBookTokens.dangerStroke
        : FinzoBookTokens.titleGreen;

    return Padding(
      padding: EdgeInsets.only(top: overflow),
      child: SizedBox(
        height: h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(r),
                  border: Border.all(
                    color: stroke,
                    width: FinzoBookTokens.cardBorderWidth,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    10 * s,
                    14 * s,
                    10 * s,
                    8 * s,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w700,
                          fontSize: FinzoBookTokens.cardTitleSize * s,
                          height: 1.15,
                          color: titleColor,
                        ),
                      ),
                      SizedBox(height: 4 * s),
                      Expanded(
                        child: Text(
                          text,
                          maxLines: illustration != null ? 5 : 7,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.rubik(
                            fontWeight: FontWeight.w500,
                            fontSize: FinzoBookTokens.cardBodySize * s,
                            height: 1.25,
                            color: FinzoBookTokens.body,
                          ),
                        ),
                      ),
                      if (illustration != null) ...[
                        SizedBox(height: 2 * s),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            height: 36 * s,
                            child: illustration,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: FinzoBookTokens.badgeLeftInset * s,
              top: -overflow,
              child: Container(
                width: badgeR * 2,
                height: badgeR * 2,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badge,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.2 * s),
                ),
                child: Text(
                  '$number',
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w800,
                    fontSize: 12 * s,
                    height: 1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ряд из двух comparison-карточек (danger | safe), как на «Книжка 2».
class BookLessonCardRow extends StatelessWidget {
  const BookLessonCardRow({super.key, required this.cards});

  final List<BookLessonCard> cards;

  @override
  Widget build(BuildContext context) {
    final s = FinzoBookTokens.contentScale;
    final gap = FinzoBookTokens.cardGap * s;
    assert(cards.length == 2, 'Comparison row expects exactly 2 cards');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 160, child: cards[0]),
        SizedBox(width: gap),
        Expanded(flex: 152, child: cards[1]),
      ],
    );
  }
}

/// Ряд из трёх mint numbered-карточек («Книжка 1»).
class BookLessonTripleRow extends StatelessWidget {
  const BookLessonTripleRow({super.key, required this.cards});

  final List<BookLessonCard> cards;

  @override
  Widget build(BuildContext context) {
    final s = FinzoBookTokens.contentScale;
    final gap = 6.0 * s;
    assert(cards.length == 3, 'Triple row expects exactly 3 cards');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }
}
