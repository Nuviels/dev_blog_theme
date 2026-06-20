---
title: 이미지와 첨부파일을 함께 넣는 예시 글
date: 2026-03-29 09:00:00 +0900
categories: [Blogging, Tutorial]
tags: [sample, image, file, markdown]
description: Chirpy 블로그 글에 이미지와 다운로드 파일을 함께 넣는 최소 예시입니다.
image:
  path: /assets/img/posts/2026-03-29/post-demo-cover.svg
  alt: 예시 포스트 커버 이미지
local_only: true
---

이 글은 Chirpy 블로그에서 글 본문에 이미지와 첨부파일 링크를 함께 넣는 예시입니다.

## 1. 본문에 이미지 넣기

아래처럼 일반 마크다운 이미지 문법을 쓰면 됩니다.

```md
![예시 이미지](/assets/img/posts/2026-03-29/post-demo-cover.svg){: w="1200" }
_이미지 캡션 예시_
```

실제 출력 예시는 아래와 같습니다.

![예시 이미지](/assets/img/posts/2026-03-29/post-demo-cover.svg){: w="1200" }
_이미지 캡션 예시_

## 2. 첨부파일 링크 넣기

다운로드 링크는 `assets/files/...` 아래에 파일을 넣고 일반 링크로 연결하면 됩니다.

```md
[샘플 텍스트 파일 다운로드](/assets/files/posts/2026-03-29/sample-checklist.txt)
[샘플 마크다운 파일 다운로드](/assets/files/posts/2026-03-29/sample-snippet.md)
```

실제 링크:

[샘플 텍스트 파일 다운로드](/assets/files/posts/2026-03-29/sample-checklist.txt)

[샘플 마크다운 파일 다운로드](/assets/files/posts/2026-03-29/sample-snippet.md)

## 3. 한 번에 복붙할 최소 예시

아래 정도만 기억하면 됩니다.

```md
---
title: 새 글 제목
date: 2026-03-29 09:00:00 +0900
categories: [Blogging, Tutorial]
tags: [sample]
---

본문에 이미지:

![설명](/assets/img/posts/2026-03-29/post-demo-cover.svg){: w="1200" }
_캡션_

본문에 첨부파일 링크:

[파일 다운로드](/assets/files/posts/2026-03-29/sample-checklist.txt)
```

## 4. 파일 배치 위치

- 이미지: `/assets/img/posts/2026-03-29/post-demo-cover.svg`
- 첨부파일: `/assets/files/posts/2026-03-29/sample-checklist.txt`
- 첨부용 마크다운 예시: `/assets/files/posts/2026-03-29/sample-snippet.md`

새 글을 쓸 때는 같은 방식으로 날짜나 폴더명만 바꿔서 넣으면 됩니다.
