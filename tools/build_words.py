#!/usr/bin/env python3
"""bataak/dict-mn-ийн mn_MN.dic-ээс тоглоомд тохирох үндсэн үгсийг шүүж
assets/data/words.txt үүсгэнэ.

Хэрэглээ:
  python3 tools/build_words.py <mn_MN.dic> [assets/data/words.txt]

Шүүлт: жижиг үсгээр бичигдсэн (товчлол, нэр хасна), зөвхөн монгол кирилл,
FORBIDDENWORD (!!) болон ONLYINCOMPOUND (oc) тэмдэгтэй биш,
урт нь MIN_LEN..MAX_LEN. Дагавар (affix) тэлэхгүй — зөвхөн үндсэн хэлбэр.
"""
import sys

MIN_LEN, MAX_LEN = 2, 9
ALPHABET = set('абвгдеёжзийклмноөпрстуүфхцчшъыьэюя')

HEADER = """\
# Монгол үгийн жагсаалт — үндсэн хэлбэрүүд (мөр бүрт нэг үг).
#
# Эх сурвалж: bataak/dict-mn — mn_MN.dic (https://github.com/bataak/dict-mn)
# Copyright 2020-2026, Batmunkh Dorjgotov
# Лиценз: Mozilla Public License 2.0 — assets/data/LICENSE-mn_MN-MPL-2.0.txt
# Өөрчлөлт: tools/build_words.py-аар шүүсэн (жижиг үсэг, {lo}-{hi} тэмдэгт,
# товчлол/нэр/дагаварын мэдээллийг хассан). Энэ файл нь MPL-2.0-ын дор байна.
#
"""


def main() -> None:
    src = sys.argv[1]
    dst = sys.argv[2] if len(sys.argv) > 2 else 'assets/data/words.txt'
    words = set()
    with open(src, encoding='utf-8') as f:
        next(f)  # эхний мөр = оруулгын тоо
        for line in f:
            line = line.rstrip('\n')
            if not line or line.startswith('#'):
                continue
            word, _, flags = line.partition('/')
            flag_list = [flags[i:i + 2] for i in range(0, len(flags), 2)]
            if '!!' in flag_list or 'oc' in flag_list:
                continue
            if word != word.lower() or not word:
                continue
            if any(ch not in ALPHABET for ch in word):
                continue
            if MIN_LEN <= len(word) <= MAX_LEN:
                words.add(word)
    with open(dst, 'w', encoding='utf-8') as out:
        out.write(HEADER.format(lo=MIN_LEN, hi=MAX_LEN))
        out.write('\n'.join(sorted(words)) + '\n')
    print(f'{len(words)} үг → {dst}')


if __name__ == '__main__':
    main()
