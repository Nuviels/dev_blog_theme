---
title: 로컬 전용 공통 포스트 템플릿
date: 2026-03-29 11:30:00 +0900
categories: [Blogging, Template]
tags: [template, local-only, chirpy]
description: 글 작성할 때 공통적으로 필요한 요소를 한 번에 모아둔 로컬 전용 템플릿입니다.
local_only: true
toc: true
comments: false
image:
  path: /assets/img/posts/2026-03-29/advanced-cover.svg
  alt: 로컬 전용 공통 포스트 템플릿 썸네일
---

이 글은 공개 전 작성용 템플릿입니다. 새 글을 만들 때 이 파일을 복사해서 제목, 날짜, 카테고리, 태그, 본문만 바꿔 쓰면 됩니다.

## Front Matter 예시

아래 블록만 먼저 바꿔도 기본 골격은 바로 쓸 수 있습니다.

```yml
---
title: 글 제목
date: 2026-03-29 11:30:00 +0900
categories: [Dev, Note]
tags: [sample, post]
description: 글 요약 한 줄
local_only: true
toc: true
comments: false
image:
  path: /assets/img/posts/2026-03-29/advanced-cover.svg
  alt: 썸네일 설명
---
```

## 요약

- 이 글의 핵심 내용을 1~3줄로 정리합니다.
- 홈 목록 설명은 `description` 에 들어가고, 여기에는 독자용 요약을 씁니다.
- 공개 전까지는 `local_only: true` 상태를 유지합니다.

## 대표 이미지

대표 이미지는 글 상단과 목록 썸네일에 사용됩니다.

![대표 이미지 예시](/assets/img/posts/2026-03-29/advanced-cover.svg){: w="1200" }
_대표 이미지 예시_

## 본문 이미지

작업 화면이나 결과 이미지는 본문 안에 이렇게 넣습니다.

![본문 이미지 1](/assets/img/posts/2026-03-29/content-shot-1.svg){: w="1200" }
_첫 번째 본문 이미지 캡션_

![본문 이미지 2](/assets/img/posts/2026-03-29/content-shot-2.svg){: w="900" .shadow }
_두 번째 본문 이미지 캡션_

## 핵심 내용

### 문제

여기에 왜 이 작업을 했는지 씁니다.

### 해결

여기에 어떤 방식으로 해결했는지 씁니다.

### 결과

여기에 결과와 배운 점을 씁니다.

## 코드 예시

```bash
bundle exec jekyll serve
```

```md
![이미지 설명](/assets/img/posts/2026-03-29/content-shot-1.svg){: w="1200" }
[PDF 다운로드](/assets/files/posts/2026-03-29/sample-guide.pdf)
```

## 첨부자료

[PDF 자료](/assets/files/posts/2026-03-29/sample-guide.pdf)

[체크리스트 TXT](/assets/files/posts/2026-03-29/sample-checklist.txt)

[마크다운 샘플](/assets/files/posts/2026-03-29/sample-snippet.md)

[압축파일 ZIP](/assets/files/posts/2026-03-29/sample-assets.zip)

## 체크리스트

- 제목, 날짜, 설명을 수정했는가
- 카테고리와 태그를 현재 글에 맞게 바꿨는가
- 대표 이미지와 본문 이미지 경로를 확인했는가
- 첨부파일 링크가 실제 파일을 가리키는가
- 공개 전이라면 `local_only: true` 상태인가

## 공개 전환 메모

로컬에서만 보이게 할 때:

```yml
local_only: true
```

공개할 때:

```yml
local_only: false
```

또는 해당 줄을 지워도 됩니다.
