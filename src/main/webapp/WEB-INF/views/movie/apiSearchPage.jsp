<%--
    파일명: apiSearchPage.jsp
    설명:
        이 JSP 파일은 OMDb API를 통해 영화를 검색하고, 그 결과를 표시하는 페이지입니다.
        일반 사용자와 관리자 모두 접근하여 영화를 검색할 수 있지만, API에서 검색된 영화를 데이터베이스에 등록하는 기능은 관리자에게만 제공됩니다.
        또한, 외부 API에서 가져온 영화 정보라도 로컬 DB에 동일한 영화가 있을 경우, 로컬 DB의 평점 및 잔혹도 평균으로 덮어씌워 표시합니다.

    목적:
        - 사용자가 외부 API(OMDb)를 통해 영화 정보를 검색할 수 있도록 제공하기 위해

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>영화 검색</title>
    <style>
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        img { max-width: 80px; height: auto; }
    </style>
</head>
<body>
    <h1>영화 검색</h1>
    <%--
        관리자에게만 보이는 "내 영화 관리페이지로 돌아가기" 링크
        목적: 관리자가 API 검색 페이지에서 직접 등록/관리하는 영화 목록 페이지로 쉽게 돌아갈 수 있도록 편의성을 제공합니다.
        변수: `${userRole}` (세션 스코프의 `userRole` 속성)
            - `movieController.java`에서 세션에 저장된 사용자 역할을 가져와 JSP의 모델에 추가한 값입니다.
            - `ADMIN` 값과 비교하여 현재 사용자가 관리자인지 확인합니다.
            - 연결: `movieController`의 `isAdmin(HttpSession session)` 메서드를 통해 세션에서 `userRole`을 가져오고, `model.addAttribute("userRole", session.getAttribute("userRole"));`로 JSP에 전달.
    --%>
    <c:if test="${userRole == 'ADMIN'}">
        <p><a href="<c:url value='/movies'/>">내 영화 관리페이지로 돌아가기</a></p>
    </c:if>

    <%--
        영화 검색 폼
        목적: 사용자가 검색어를 입력하여 OMDb API를 통해 영화를 검색하도록 합니다.
        `action="<c:url value='/search'/>"`:
            - 폼 제출 시 `movieController.java`의 `searchMoviesFromHeader` (GET /search) 메서드가 호출됩니다.
            - 이 컨트롤러 메서드는 `externalMovieApiService`를 사용하여 실제 API 검색을 수행합니다.
        `name="query"`:
            - 사용자가 입력한 검색어가 이 이름으로 HTTP 요청 파라미터로 전송됩니다.
            - `movieController`의 `@RequestParam("query") String query`로 이 값을 받습니다.
        `value="${query}"`:
            - 검색 후 페이지가 다시 로드될 때, 이전에 검색했던 키워드를 입력 필드에 다시 표시하여 사용자 편의성을 높입니다.
            - `movieController`에서 `model.addAttribute("query", query);`를 통해 전달된 값입니다.
    --%>
    <form action="<c:url value='/search'/>" method="get">
        영화 제목 또는 키워드: <input type="text" name="query" value="${query}" placeholder="영화 검색..." />
        <button type="submit">검색</button>
    </form>

    <hr>

    <c:if test="${searchPerformed}">

        <c:if test="${not empty param.error && param.error == 'detailNotFound'}">
            <p style="color: red;">선택하신 영화의 상세 정보를 가져오거나 등록할 수 없었습니다.</p>
        </c:if>

        <h2>"${query}" 검색 결과</h2>
        <c:if test="${empty apiMovies}">
            <p>검색 결과가 없습니다. 다른 키워드로 검색해보세요.</p>
        </c:if>
        <%--
            검색 결과가 있는 경우
            `apiMovies` 리스트를 반복하여 각 영화 정보를 테이블 행으로 표시합니다.
        --%>
        <c:if test="${not empty apiMovies}">
            <table>
                <thead>
                    <tr>
                        <th>포스터</th>
                        <th>제목</th>
                        <th>감독</th>
                        <th>연도</th>
                        <th>장르</th>
                        <th>평점</th>
                        <th>폭력성</th>
                        <th>개요</th>
                        <%-- '동작' 열도 관리자에게만 보이도록 함--%>
                        <c:if test="${userRole == 'ADMIN'}">
                            <th>IMDb ID</th>
                            <th>동작</th>
                        </c:if>
                    </tr>
                </thead>
                <tbody>
                    <%--
                        `c:forEach` 루프: `apiMovies` 리스트의 각 `movie` 객체에 대해 반복합니다.
                        `var="apiMovie"`: 현재 반복 중인 `movie` 객체를 참조할 변수 이름입니다.
                    --%>
                    <c:forEach var="apiMovie" items="${apiMovies}">
                        <tr>
                            <td>
                                <%--
                                    포스터 이미지 처리
                                    목적: OMDb API에서 제공하는 포스터 이미지를 표시하거나, 이미지가 없을 경우 기본 이미지를 표시합니다.
                                    `movie.posterPath`: `externalMovieApiService.java`에서 OMDb API 응답을 파싱하여 `movie` 객체에 설정된 포스터 URL입니다.
                                    `fn:startsWith(..., 'http://')` 또는 `https://`:
                                        - JSTL Functions 라이브러리(`fn`)를 사용하여 `posterPath`가 완전한 URL인지 확인합니다.(자꾸 이미지 깨져서 해당 함수 추가)
                                        - OMDb에서 가져온 이미지는 외부 URL이므로 직접 사용하고, 로컬에 저장된 이미지는 컨텍스트 경로를 붙여 사용해야 합니다.
                                        - `externalMovieApiService`에서 가져온 포스터는 대부분 외부 URL이므로, 이 조건문은 로컬 이미지와 외부 이미지를 구분합니다.
                                    `default_poster.jpg`:
                                        - `posterPath`가 없거나 "N/A"일 경우 표시되는 기본 이미지입니다.
                                        - `movieController.java`에서 API 응답에 포스터가 없을 때 "N/A"로 설정됩니다.
                                --%>
                                <c:choose>
                                    <c:when test="${not empty apiMovie.posterPath and apiMovie.posterPath ne 'N/A'}">
                                        <img src="${apiMovie.posterPath}" alt="${apiMovie.title} 포스터" />
                                    </c:when>
                                    <c:otherwise>
                                                         <%--  이미지 출처는 https://commons.wikimedia.org/wiki/File:No-Image-Placeholder.svg
                                        <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png/>" alt="기본 포스터" /> --%>
                                        <img src="<c:url value='/resources/images/movies/default_poster.jpg'/>" alt="기본 포스터" />
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <%--
                                    영화 제목 링크
                                    목적: 검색 결과의 영화 제목을 클릭하면 해당 영화의 상세 페이지로 이동하도록 합니다.
                                    `href="<c:url value='/movies/api-external-detail?imdbId=${apiMovie.apiId}'/>"`:
                                        - `movieController.java`의 `getApiExternalMovieDetail` (GET /movies/api-external-detail) 메서드를 호출합니다.
                                        - `imdbId` 쿼리 파라미터로 현재 영화의 IMDb ID (`apiMovie.apiId`)를 넘겨줍니다.
                                        - 이 컨트롤러는 다시 `externalMovieApiService`를 호출하여 해당 IMDb ID의 상세 정보를 가져와 상세 페이지(`detailPage.jsp`)로 전달합니다.
                                --%>
                                <a href="<c:url value='/movies/api-external-detail?imdbId=${apiMovie.apiId}'/>" class="title-as-link">
                                    ${apiMovie.title}
                                </a>
                            </td>
                            <%-- 영화 정보 표시--%>
                            <td>${apiMovie.director}</td>
                            <td>${apiMovie.year}</td>
                            <td>${apiMovie.genre}</td>
                            <td>
                                <%--
                                    평점 표시 (로컬 DB 우선)
                                    목적: OMDb API에서 가져온 초기 평점 대신, 로컬 DB에 저장된 평점(사용자 리뷰 기반)이 있다면 그 값을 우선적으로 표시합니다.
                                    `movie.rating`: `movie` 도메인 객체의 평점 필드입니다.
                                    `movieController.java`의 `overrideRatingsWithLocalData` 헬퍼 메서드가 이 로직을 담당합니다.
                                        - API 검색 후, 각 `apiMovie`에 대해 `movieService.findByApiId(apiMovie.getApiId())`를 호출하여 로컬 DB의 `movie` 객체를 찾습니다.
                                        - 만약 로컬 DB에 해당 영화가 있다면, `apiMovie.setRating(localMovie.getRating());`을 통해 평점을 덮어씌웁니다.
                                    `0.0` 체크:
                                        - `externalMovieApiService`에서 OMDb 평점을 가져오지 않고 `0.0`으로 고정했기 때문에, 로컬 DB에 평점이 없는 경우 `0.0`이 될 것입니다.
                                        - `fmt:formatNumber`: 소수점 첫째 자리까지 포맷팅하여 표시합니다.
                                --%>
                                <c:choose>
                                    <c:when test="${apiMovie.rating == 0.0}">
                                        N/A 
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${apiMovie.rating}" pattern="#0.0" />
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <%--
                                    잔혹도 평균 표시 (로컬 DB 우선)
                                    목적: 평점과 동일하게, 로컬 DB에 저장된 잔혹도 평균이 있다면 그 값을 우선적으로 표시합니다.
                                    `movie.violence_score_avg`: `movie` 도메인 객체의 폭력성 평균 필드입니다.
                                    `movieController.java`의 `overrideRatingsWithLocalData` 헬퍼 메서드가 이 로직을 담당합니다.
                                        - `apiMovie.setviolence_score_avg(localMovie.getviolence_score_avg());`를 통해 덮어씌웁니다.
                                    - 목적: 사이트 고유의 폭력성 평가 시스템을 강조합니다.
                                --%>
                                <c:choose>
                                    <c:when test="${apiMovie.violence_score_avg == 0.0}">
                                        N/A <%-- 폭력성 평균이 0.0이면 N/A 표시--%>
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${apiMovie.violence_score_avg}" pattern="#0.0" />
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${fn:substring(apiMovie.overview, 0, 30)}...</td>
                            <%-- 관리자에게만 'IMDb ID'와 '동작' (영화 등록 버튼) 표시--%>
                            <c:if test="${userRole == 'ADMIN'}">
                                <td>${apiMovie.apiId}</td>
                                <td>
                                    <%--
                                        영화 등록 폼 (관리자 전용)
                                        목적: 관리자가 API 검색 결과 중 원하는 영화를 클릭 한 번으로 로컬 DB에 등록할 수 있도록 합니다.
                                        `action="<c:url value='/movies/import-api-detail'/>"`:
                                            - `movieController.java`의 `importApiMovieDetail` (POST /movies/import-api-detail) 메서드를 호출합니다.
                                        `name="imdbId"`:
                                            - 숨겨진 입력 필드를 사용하여 현재 영화의 IMDb ID (`apiMovie.apiId`)를 서버로 전송합니다.
                                            - `movieController`에서 `@RequestParam("imdbId") String imdbId`로 이 값을 받습니다.
                                        - 연결: `movieController`는 이 IMDb ID를 사용하여 `externalMovieApiService.getMovieFromApi(imdbId)`를 호출해 상세 정보를 다시 가져온 후, `movieService.save(movieFromApi)`를 통해 DB에 저장합니다.
                                    --%>
                                    <form action="<c:url value='/movies/import-api-detail'/>" method="post" style="display:inline;">
                                        <input type="hidden" name="imdbId" value="${apiMovie.apiId}" /><button type="submit">이 영화 등록</button>
                                    </form>
                                </td>
                            </c:if>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
    </c:if>
</body>
</html>