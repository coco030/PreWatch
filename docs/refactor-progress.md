# PreWatch 리팩토링 진행 기록

작성 기준: 2026-06-08  
작업본: `D:\project_prewatch\PreWatch-refactor-lab`

이 문서는 GitHub 반영 전 변경 내용을 잊지 않기 위한 작업 기록이다.  
현재 리팩토링 원칙은 기능 결과를 크게 바꾸지 않고, 먼저 읽기 쉬움과 유지보수 가능성을 높이는 것이다.

## 완료한 작업

### 1. 리팩토링 실험용 작업본 분리

- 기존 프로젝트를 직접 망가뜨리지 않기 위해 `PreWatch-refactor-lab` 작업본을 별도로 사용한다.
- GitHub에 올라가는 Maven 식별자는 기존 프로젝트 이름을 유지한다.
  - `artifactId`: `PreWatch`
  - `name`: `PreWatch Maven Webapp`
- 실제 API 키가 들어 있는 `src/main/resources/application.properties`는 로컬 작업본에만 두고, `.gitignore`에 포함되어 GitHub에 올라가지 않도록 유지한다.

### 2. 추천/취향 분석 알고리즘 문서화

- `docs/recommendation-algorithm.md`에 추천 알고리즘과 취향 분석 로직의 의도를 정리했다.
- `StatServiceImpl`, `TasteProfileServiceImpl`의 계산 결과는 바꾸지 않았다.
- 임계값은 데이터가 부족한 개인 프로젝트에서 선택한 휴리스틱 기준으로 설명했다.
- 당장은 임계값을 의미 없이 상수로 옮기거나 숫자를 바꾸지 않기로 정리했다.

### 3. API 영화 상세 진입 시 저장 흐름 정리

- API 외부 상세 페이지에 들어온 영화가 이미 DB에 있으면 기존 DB 상세 페이지로 이동하게 했다.
- 로그인한 회원 또는 관리자가 API 영화 상세 페이지를 열면, 필요한 경우 영화를 DB에 저장한 뒤 DB 상세 페이지로 이동하게 했다.
- API 영화 등록 POST 흐름에서도 이미 등록된 영화는 중복 저장하지 않고 기존 상세 페이지로 이동하게 했다.
- 관련 파일:
  - `src/main/java/com/springmvc/controller/MovieController.java`
  - `src/main/java/com/springmvc/service/TmdbApiService.java`

### 4. 배우/감독 정보 저장 비용 줄이기

- 영화 저장 시 배우/감독 연결 정보는 저장하되, 인물 상세 정보는 전부 즉시 가져오지 않도록 했다.
- 배우/감독 상세 페이지를 열 때 필요한 경우에만 인물 상세 정보를 보강하도록 했다.
- 이 방식으로 추천/취향 분석에 필요한 `actors`, `movie_actors` 연결은 유지하면서 상세 페이지 진입 비용을 줄였다.
- 관련 파일:
  - `src/main/java/com/springmvc/controller/ActorController.java`
  - `src/main/java/com/springmvc/service/TmdbApiService.java`

### 5. 영화 상세 페이지 API 호출 감소

- 상세 페이지에서 DB에 저장된 출연진 정보가 있으면 TMDB 출연진 API를 다시 호출하지 않게 했다.
- 이미지가 DB에 저장되어 있으면 TMDB 이미지 API를 다시 호출하지 않게 했다.
- 이미지가 없을 때만 TMDB에서 배경 이미지를 가져오고, 가져온 이미지는 DB에 저장해 다음 조회에서 재사용하게 했다.
- 배경 이미지는 저장된 이미지가 있으면 그 값을 먼저 사용하고, 없을 때만 `backdrop_path`를 조회한다.
- 관련 파일:
  - `src/main/java/com/springmvc/controller/MovieController.java`
  - `src/main/java/com/springmvc/service/MovieImageServiceImpl.java`
  - `src/main/webapp/WEB-INF/views/movie/detailPage.jsp`

### 6. TMDB 조회값 서버 실행 중 재사용

- 같은 서버 실행 중 반복 조회되는 TMDB 값을 메모리 캐시로 재사용하게 했다.
- 캐시 대상:
  - 출연진/제작진 목록
  - 배경 이미지 URL 목록
  - 배경 이미지 path
  - TMDB 평점
- 실패한 API 응답은 캐시에 넣지 않는다.
- DB 구조나 추천 알고리즘은 변경하지 않았다.
- 관련 파일:
  - `src/main/java/com/springmvc/service/TmdbApiService.java`

### 7. 별점/점수 아이콘 흔들림 개선

- 기존 별/원 아이콘 교체 방식 대신, 빈 아이콘 위에 채워진 아이콘을 겹치고 `width`만 조절하는 방식으로 바꿨다.
- 10점 단위 점수를 5개 아이콘의 반칸 단위로 표시하는 구조는 유지했다.
- 마우스를 올릴 때 아이콘 크기가 달라져 흔들리는 문제를 줄였다.
- 관련 파일:
  - `src/main/webapp/WEB-INF/views/reviewModule/userRatingForm.jsp`
  - `src/main/webapp/WEB-INF/views/reviewModule/violenceScoreForm.jsp`
  - `src/main/webapp/WEB-INF/views/reviewModule/horrorScoreForm.jsp`
  - `src/main/webapp/WEB-INF/views/reviewModule/sexualScoreForm.jsp`

### 8. 점수 입력 말풍선 안내 추가

- 만족도, 폭력성, 공포, 선정성 점수에 hover/click 안내 문구를 추가했다.
- 안내 문구는 서버 요청 없이 JSP 안의 JavaScript 배열로 처리한다.
- 점수 저장 AJAX 흐름은 변경하지 않았다.
- 말풍선은 absolute 레이어로 표시해 아래 점수 입력 영역이 밀리지 않게 했다.
- 점수 구간 숫자는 말풍선에서 제거하고, 옆의 점수 라벨만 숫자를 보여주게 했다.
- 현재 말풍선은 정답 기준이 아니라 사용자가 점수를 찍을 때 참고하는 짧은 체감 문구로 둔다.
- 구체적인 트리거/주의 요소는 기존 `주의` 섹션이 담당한다.
- 관련 파일:
  - `src/main/webapp/WEB-INF/views/reviewModule/userRatingForm.jsp`
  - `src/main/webapp/WEB-INF/views/reviewModule/violenceScoreForm.jsp`
  - `src/main/webapp/WEB-INF/views/reviewModule/horrorScoreForm.jsp`
  - `src/main/webapp/WEB-INF/views/reviewModule/sexualScoreForm.jsp`

### 9. 리뷰 점수 UI 공통 CSS/JS 분리

- 네 개 점수 JSP에 반복되던 CSS와 JavaScript를 공통 파일로 분리했다.
- 만족도/폭력성/공포/선정성 JSP 파일은 유지하고, 각 파일에는 색상, 저장 URL, 전송 필드명, 안내 문구 같은 설정만 남겼다.
- 점수 저장 AJAX, 반칸 hover, 아이콘 채움, 말풍선 표시 로직은 `rating-score.js`에서 공통 처리한다.
- 말풍선과 아이콘 스타일은 `rating-score.css`에서 공통 처리한다.
- 상세 페이지에서 공통 CSS/JS를 한 번만 로드한다.
- 관련 파일:
  - `src/main/webapp/resources/css/rating-score.css`
  - `src/main/webapp/resources/js/rating-score.js`
  - `src/main/webapp/WEB-INF/views/movie/detailPage.jsp`
  - `src/main/webapp/WEB-INF/views/reviewModule/userRatingForm.jsp`
  - `src/main/webapp/WEB-INF/views/reviewModule/violenceScoreForm.jsp`
  - `src/main/webapp/WEB-INF/views/reviewModule/horrorScoreForm.jsp`
  - `src/main/webapp/WEB-INF/views/reviewModule/sexualScoreForm.jsp`

## 현재 보류한 판단

- 영화 집계 점수 컬럼을 `movies`와 `movie_stats` 중 어디에 둘지는 아직 바꾸지 않는다.
- 추천/취향 분석 알고리즘의 계산식과 임계값은 아직 바꾸지 않는다.
- 회원가입 시 긴 설문을 추가하는 방식은 우선 보류한다.
- 폭력성, 공포성, 선정성 점수는 객관적인 등급표가 아니라 사용자 체감 참고값으로 둔다.
- 구체적인 폭력/공포/선정성 트리거는 별점 문구보다 `warning_tags` 기반 주의 요소로 보여주는 것이 낫다.

## 다음 리팩토링 우선순위

### 1순위: 현재 변경사항 직접 확인

- 이클립스에서 프로젝트 새로고침 후 상세 페이지를 직접 확인한다.
- 확인할 흐름:
  - API 검색 결과에서 영화 상세 페이지 진입
  - 저장된 영화는 DB 상세 페이지로 이동하는지
  - 상세 페이지 이미지와 출연진이 정상 표시되는지
  - 배우/감독 상세 페이지 진입 시 오류가 없는지
  - 만족도/폭력성/공포/선정성 점수 저장 AJAX가 정상 동작하는지
  - 말풍선이 아래 요소를 밀지 않는지

### 2순위: 홈 화면 안정화

- `home.jsp`에서 주석 처리된 통계 요소를 JavaScript가 계속 찾는 부분을 정리한다.
- `HomeController`와 `GlobalControllerAdvice`에서 `globalStats`를 중복 조회하는 흐름을 확인한다.
- 메인 화면을 크게 바꾸기 전에 작은 오류와 중복 조회부터 줄인다.

### 3순위: 추천/취향 분석 SQL 책임 표시

- `StatRepository`, `TasteProfileServiceImpl`, `StatServiceImpl`에서 어떤 조회가 어떤 알고리즘 단계에 쓰이는지 표시한다.
- SQL 결과나 추천 결과는 바꾸지 않는다.
- 목표는 코드를 읽을 때 “이 조회가 왜 필요한지” 빠르게 알 수 있게 하는 것이다.

### 4순위: 작은 테스트 데이터 만들기

- 알고리즘 변경 전후 비교를 위한 작은 테스트 데이터를 만든다.
- 목적은 추천 결과가 의도치 않게 바뀌는지 확인하는 것이다.
- 이 작업 전까지는 추천 계산식 변경을 하지 않는다.

### 5순위: 상세 페이지 성능 추가 점검

- 실제 실행 후 아직 느린 부분이 있으면 확인한다.
- 후보:
  - TMDB 평점 저장 방식
  - 추천 목록 계산 비용
  - 이미지 크기와 로딩 방식
  - 상세 페이지에서 동시에 실행되는 DB 조회 수

### 6순위: DB 구조 검토

- `movies.rating`, `movies.violence_score_avg`, `movie_stats.horror_score_avg`, `movie_stats.sexual_score_avg`처럼 집계 점수가 분산되어 있다.
- 다만 추천 알고리즘이 강하게 의존하므로 바로 합치지 않는다.
- Repository 책임 정리와 테스트 데이터 준비 후 별도 작업으로 검토한다.

## GitHub 반영 전 체크리스트

- `src/main/resources/application.properties`가 올라가지 않는지 확인한다.
- 실제 API 키 값은 문서, 커밋 메시지, README에 적지 않는다.
- 기능별로 커밋을 나눌 수 있다면 아래처럼 나눈다.
  1. 알고리즘 문서화
  2. API 영화 저장/상세 진입 흐름 개선
  3. 상세 페이지 API 호출 감소
  4. 점수 아이콘 UI 개선
  5. 점수 입력 안내 말풍선 추가
- 변경 후 최소 확인 명령:
  - `mvn -q -DskipTests package`

### 10. 상세 페이지 평가/주의 요소와 로그인 진입 UX 개선

- 상세 페이지의 주의 요소 아이콘에 PC hover용 말풍선을 추가하고, 클릭 시 전체 주의 요소 펼치기는 유지했다.
- 터치 기기에서는 주의 요소 말풍선을 숨기고, 아이콘 탭으로 전체 목록을 펼치는 흐름을 유지했다.
- 만족도/폭력성/공포/선정성 점수 입력 공통 JS를 모바일 터치 입력에 맞게 보완했다.
- 비로그인 상태에서 평가나 찜을 시도할 때 alert 대신 로그인 모달을 열도록 바꿨다.
- 로그인 모달에 회원가입 버튼을 추가하고, 비로그인 리뷰 입력 문구를 `리뷰작성을 해주시겠어요?`로 변경했다.
- 헤더의 로그인/회원가입 링크는 기존 `login.jsp`, `joinForm.jsp` 페이지를 작은 iframe 모달 안에 띄우도록 변경했다.
- 관련 파일:
  - `src/main/webapp/WEB-INF/views/authFrameModal.jsp`
  - `src/main/webapp/WEB-INF/views/layout/header.jsp`
  - `src/main/webapp/WEB-INF/views/layout/header-right.jsp`
  - `src/main/webapp/WEB-INF/views/loginModal.jsp`
  - `src/main/webapp/WEB-INF/views/movie/detailPage.jsp`
  - `src/main/webapp/WEB-INF/views/reviewModule/reviewContentForm.jsp`
  - `src/main/webapp/resources/css/layout.css`
  - `src/main/webapp/resources/css/rating-score.css`
  - `src/main/webapp/resources/js/rating-score.js`
