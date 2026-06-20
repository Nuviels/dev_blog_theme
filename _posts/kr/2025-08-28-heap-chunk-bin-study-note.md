---
title: glibc heap chunk와 bin 구조 학습 노트
date: 2025-08-28 01:03:00 +0900
categories: [Pwnable, Heap]
tags: [heap, glibc, malloc, bin, pwnable]
description: glibc malloc의 chunk 메타데이터와 fastbin, unsorted bin, smallbin, largebin, main_arena의 동작을 정리한 학습 노트입니다.
local_only: true
toc: true
comments: false
---

> 이 글은 Greedun님의 Tistory 글을 참고해 개인 학습용으로 재구성한 요약 노트입니다.  
> 원문: <https://greedun.tistory.com/145>

## 1. Heap chunk 구조

glibc malloc에서 heap chunk는 사용자 데이터 앞쪽에 메타데이터를 가진다. 이 메타데이터는 chunk의 크기, 이전 chunk 상태, free list 연결 정보 등을 표현한다.

### 사용 중인 chunk

사용 중인 chunk에서 중요한 필드는 다음과 같다.

- `prev_size`: 바로 앞 chunk가 free 상태일 때, 그 이전 chunk의 크기를 저장한다.
- `size`: 현재 chunk의 전체 크기다. 사용자 요청 크기뿐 아니라 헤더 크기와 flag bit가 포함된다.
- `data`: `malloc` 호출자가 실제로 사용하는 영역이다.

`size`의 하위 bit는 정렬 특성 때문에 flag로 사용된다.

- `PREV_INUSE`, `0x1`: 이전 chunk가 사용 중이면 설정된다.
- `IS_MMAPPED`, `0x2`: `mmap()`으로 할당된 chunk임을 나타낸다.
- `NON_MAIN_ARENA`, `0x4`: main arena가 아닌 arena에서 관리되는 chunk임을 나타낸다.

### 해제된 chunk

chunk가 free되면 사용자 데이터 영역 일부가 bin 연결을 위한 포인터로 재사용된다.

- `fd`: forward pointer. 같은 bin 안에서 다음 free chunk를 가리킨다.
- `bk`: backward pointer. 이중 연결 리스트에서 이전 free chunk를 가리킨다.
- `fd_nextsize`: largebin에서 크기 기준 순회를 위해 사용된다.
- `bk_nextsize`: largebin에서 크기 기준 역방향 순회를 위해 사용된다.

즉 free chunk의 data 영역은 더 이상 사용자 데이터가 아니라 allocator 내부 자료구조의 일부로 쓰인다.

## 2. Bin 개요

bin은 free된 chunk를 크기와 용도에 따라 보관하는 allocator 내부의 저장소다. glibc malloc은 요청 크기와 chunk 상태에 따라 여러 종류의 bin을 사용한다.

| 종류 | 특징 |
| --- | --- |
| `fastbin` | 작은 크기의 chunk를 빠르게 재사용하기 위한 단일 연결 리스트 |
| `tcache` | glibc 2.26 이후 추가된 thread-local cache |
| `unsorted bin` | small/large chunk가 free된 직후 임시로 들어가는 bin |
| `smallbin` | 고정 크기 단위로 관리되는 이중 연결 리스트 |
| `largebin` | 큰 chunk를 크기 범위별로 정렬해 관리하는 bin |

`tcache`와 `fastbin`은 관리 크기 범위가 일부 겹친다. 최신 glibc에서는 tcache가 먼저 사용되고, tcache가 가득 차거나 대상 범위를 벗어나는 경우 fastbin이나 다른 bin 경로가 사용된다.

## 3. Fastbin

fastbin은 작은 chunk를 빠르게 재사용하기 위한 구조다. 같은 크기 class의 free chunk를 단일 연결 리스트로 관리하며, LIFO 방식으로 동작한다.

### 특징

- 단일 연결 리스트를 사용한다.
- 최근 free된 chunk가 먼저 재할당된다.
- 검증 루틴이 상대적으로 적어 빠르다.
- 인접한 chunk가 free되어도 즉시 병합하지 않는다.

### `free()` 시 동작

fastbin 크기 범위의 chunk가 해제되면 allocator는 해당 크기에 맞는 fastbin index를 계산한다. 이후 현재 fastbin head를 해제할 chunk의 `fd`에 저장하고, bin head를 새 chunk로 갱신한다.

개념적으로는 다음과 같은 흐름이다.

```text
free chunk -> fd = old fastbin head
fastbin head = free chunk
```

이 구조 때문에 fastbin은 stack처럼 동작한다.

### `malloc()` 시 동작

요청 크기가 fastbin 범위에 들어오면 allocator는 해당 크기 class의 fastbin을 확인한다. bin이 비어 있지 않다면 head chunk를 꺼내고, head를 그 chunk의 `fd`로 갱신한 뒤 사용자 포인터를 반환한다.

```text
victim = fastbin head
fastbin head = victim->fd
return chunk2mem(victim)
```

이 과정에서 chunk size가 기대한 fastbin index와 맞는지 검증한다. 맞지 않으면 heap metadata corruption으로 판단될 수 있다.

## 4. Top chunk

top chunk는 heap 영역에서 아직 개별 chunk로 잘려 나가지 않은 남은 공간이다. allocator가 기존 bin에서 요청을 처리할 수 없을 때 top chunk를 잘라 새 chunk를 만들 수 있다.

smallbin이나 largebin 크기의 chunk가 top chunk 근처에서 free될 경우 top chunk와 병합될 수 있다. 반대로 요청 크기가 top chunk로 처리하기에 너무 크거나 조건이 맞지 않으면 `mmap()`을 통해 별도의 매핑이 사용될 수 있다.

## 5. Unsorted bin

unsorted bin은 smallbin 또는 largebin 크기의 chunk가 free된 직후 임시로 들어가는 bin이다. 해제된 chunk가 곧바로 정확한 smallbin/largebin으로 분류되는 것이 아니라, 다음 `malloc()` 요청 처리 과정에서 먼저 검사된다.

### 특징

- 크기 제한이 사실상 없다.
- 원형 이중 연결 리스트로 관리된다.
- 새로 free된 큰 chunk를 우선 재사용할 기회를 준다.
- 적절한 요청이 없으면 이후 smallbin 또는 largebin으로 분류된다.

### 재할당 흐름

`malloc()` 요청이 들어오면 allocator는 unsorted bin을 먼저 확인한다. 요청 크기를 만족하는 chunk가 있으면 그대로 사용하거나 쪼개서 할당한다. 쪼개고 남은 remainder chunk는 크기에 따라 fastbin 또는 unsorted bin으로 다시 들어갈 수 있다.

원하는 chunk가 없다면 unsorted bin에 있던 chunk들은 알맞은 smallbin 또는 largebin으로 이동하고, allocator는 다른 경로를 통해 요청을 처리한다.

## 6. Smallbin

smallbin은 fastbin보다 크고 largebin보다 작은 chunk를 관리한다. 같은 크기의 chunk끼리 하나의 bin에 들어가며, 원형 이중 연결 리스트 구조를 사용한다.

### 특징

- 크기별로 bin index가 고정된다.
- `fd`, `bk`를 이용해 이중 연결 리스트를 구성한다.
- fastbin과 달리 연결 해제 과정에서 앞뒤 포인터 일관성 검사가 중요하다.
- 일반적으로 FIFO 성격으로 chunk를 재사용한다.

### `malloc()` 시 동작

요청 크기가 smallbin 범위라면 allocator는 해당 크기의 smallbin index를 계산한다. 대상 bin에 chunk가 있으면 리스트에서 하나를 unlink하고 in-use bit를 설정한 뒤 사용자 포인터를 반환한다.

이때 `bk->fd`가 victim을 제대로 가리키는지 같은 무결성 검사가 수행된다. 이 검사는 classic unsafe unlink류 공격을 완화하는 핵심 방어 중 하나다.

## 7. Largebin

largebin은 smallbin보다 큰 chunk를 관리한다. smallbin처럼 원형 이중 연결 리스트를 사용하지만, 단순히 동일 크기별 bin이 아니라 크기 범위별로 정렬된 구조를 가진다.

### 특징

- 큰 chunk를 크기 범위별 bin에 저장한다.
- `fd`, `bk`는 bin 내부의 기본 연결에 사용된다.
- `fd_nextsize`, `bk_nextsize`는 크기 순서 탐색에 사용된다.
- 요청 크기를 만족하는 chunk를 찾고, 필요하면 split한다.

### 재할당 흐름

요청 크기가 largebin 범위라면 allocator는 largebin 내부를 크기 기준으로 순회해 적절한 chunk를 찾는다. 요청보다 큰 chunk가 선택되면 필요한 만큼만 잘라 반환하고, 남은 부분은 remainder chunk로 관리한다.

largebin은 크기 정렬과 nextsize pointer 때문에 smallbin보다 metadata 관계가 복잡하다. 따라서 largebin 관련 exploit에서는 `fd/bk`뿐 아니라 `fd_nextsize/bk_nextsize`의 일관성도 중요한 관찰 지점이 된다.

## 8. main_arena

`main_arena`는 glibc malloc이 heap을 관리하기 위해 사용하는 대표적인 `malloc_state` 구조체다. arena 안에는 fastbin 배열, top chunk 포인터, last remainder, normal bin 배열, binmap 등이 포함된다.

주요 필드는 다음과 같다.

- `mutex`: arena 접근 동기화에 사용된다.
- `flags`: arena 상태 flag를 저장한다.
- `fastbinsY`: fastbin 배열이다.
- `top`: top chunk를 가리킨다.
- `last_remainder`: split 후 남은 최근 remainder chunk를 추적한다.
- `bins`: unsorted, small, large bin을 포함하는 normal bin 영역이다.
- `binmap`: bin 사용 여부를 빠르게 확인하기 위한 bitmap이다.
- `next`, `next_free`: arena 연결 리스트 관리에 사용된다.
- `system_mem`, `max_system_mem`: arena가 시스템에서 확보한 메모리 크기 정보를 저장한다.

요청 크기가 top chunk보다 크거나 arena에서 처리하기 부적절한 경우 allocator는 `mmap()` 기반 할당을 사용할 수 있다. 이 경우 해당 chunk는 `IS_MMAPPED` flag를 통해 구분된다.

## 9. 정리

glibc heap allocator를 이해할 때 핵심은 chunk metadata와 bin별 연결 방식이다.

- fastbin은 빠른 재사용을 위해 LIFO 단일 연결 리스트를 사용한다.
- unsorted bin은 free 직후의 큰 chunk를 임시로 보관하며 재사용 기회를 먼저 준다.
- smallbin은 고정 크기별 원형 이중 연결 리스트다.
- largebin은 큰 chunk를 크기 범위와 정렬 기준으로 관리한다.
- main_arena는 이런 bin과 top chunk를 포함하는 allocator의 중심 상태 구조체다.

heap exploit을 공부할 때는 각 bin의 연결 방식, metadata 검증 조건, chunk 병합 여부, tcache 우선순위를 함께 봐야 한다.

## 참고

- Greedun, "1_heap 청크, bin들의 구조 및 원리", Tistory, 2025-08-28: <https://greedun.tistory.com/145>
