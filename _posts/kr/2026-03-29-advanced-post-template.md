---
title: 이미지 여러 장, PDF 첨부, 썸네일까지 포함한 글 템플릿
date: 2026-03-29 10:30:00 +0900
categories: [Blogging, Tutorial]
tags: [template, image, pdf, attachment, chirpy]
description: Chirpy에서 썸네일, 본문 이미지 여러 장, PDF와 첨부파일 링크를 함께 쓰는 실전형 예시입니다.
image:
  path: /assets/img/posts/2026-03-29/advanced-cover.svg
  alt: 실전형 포스트 썸네일 예시
local_only: true
---

이 예시는 실제로 많이 쓰는 형태를 한 번에 모아둔 템플릿입니다.

## 1. 썸네일 이미지

포스트 목록과 상단 대표 이미지에는 front matter의 `image`를 사용합니다.

```yml
---
image:
  path: /assets/img/posts/2026-03-29/advanced-cover.svg
  alt: 실전형 포스트 썸네일 예시
---
```

## 2. 본문 이미지 여러 장

첫 번째 이미지는 캡션과 함께 크게 넣고:

```md
![메인 예시 이미지](/assets/img/posts/2026-03-29/content-shot-1.svg){: w="1200" }
_첫 번째 본문 이미지 캡션_
```

![메인 예시 이미지](/assets/img/posts/2026-03-29/content-shot-1.svg){: w="1200" }
_첫 번째 본문 이미지 캡션_

두 번째 이미지는 조금 작은 보조 이미지로 넣을 수 있습니다.

```md
![보조 예시 이미지](/assets/img/posts/2026-03-29/content-shot-2.svg){: w="900" .shadow }
_두 번째 본문 이미지 캡션_
```

![보조 예시 이미지](/assets/img/posts/2026-03-29/content-shot-2.svg){: w="900" .shadow }
_두 번째 본문 이미지 캡션_

## 3. PDF 첨부

PDF는 일반 링크로 연결하면 다운로드하거나 새 탭에서 열 수 있습니다.

```md
[PDF 자료 보기](/assets/files/posts/2026-03-29/sample-guide.pdf)
```

[PDF 자료 보기](/assets/files/posts/2026-03-29/sample-guide.pdf)

## 4. 기타 첨부파일

체크리스트, 코드 샘플, 압축파일도 같은 방식입니다.

```md
[체크리스트 TXT 다운로드](/assets/files/posts/2026-03-29/sample-checklist.txt)
[마크다운 샘플 다운로드](/assets/files/posts/2026-03-29/sample-snippet.md)
[압축파일 다운로드](/assets/files/posts/2026-03-29/sample-assets.zip)
```

[체크리스트 TXT 다운로드](/assets/files/posts/2026-03-29/sample-checklist.txt)

[마크다운 샘플 다운로드](/assets/files/posts/2026-03-29/sample-snippet.md)

[압축파일 다운로드](/assets/files/posts/2026-03-29/sample-assets.zip)

## 5. 그대로 복붙할 실전 템플릿

```md
---
title: 프로젝트 회고
date: 2026-03-29 10:30:00 +0900
categories: [Dev, Review]
tags: [project, review]
description: 프로젝트 작업 내용을 이미지와 첨부파일로 정리한 글입니다.
image:
  path: /assets/img/posts/2026-03-29/advanced-cover.svg
  alt: 프로젝트 회고 썸네일
---

프로젝트 요약 문장입니다.

## 작업 화면

![작업 화면 1](/assets/img/posts/2026-03-29/content-shot-1.svg){: w="1200" }
_핵심 화면 설명_

![작업 화면 2](/assets/img/posts/2026-03-29/content-shot-2.svg){: w="900" .shadow }
_보조 화면 설명_

## 첨부자료

[발표 PDF](/assets/files/posts/2026-03-29/sample-guide.pdf)

[정리 문서](/assets/files/posts/2026-03-29/sample-snippet.md)

[압축 파일](/assets/files/posts/2026-03-29/sample-assets.zip)
```

## 6. 추천 폴더 구조

- 썸네일/본문 이미지: `/assets/img/posts/날짜-또는-글이름/`
- PDF/첨부파일: `/assets/files/posts/날짜-또는-글이름/`
- 포스트 파일: `/_posts/kr/YYYY-MM-DD-title.md`

이 구조로 맞춰두면 글이 늘어나도 관리가 편합니다.
