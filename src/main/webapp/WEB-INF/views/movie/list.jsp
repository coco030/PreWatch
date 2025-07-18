<%--
    파일명: list.jsp
    설명:
        이 JSP 파일은 데이터베이스에 등록된 모든 영화 목록을 표시하는 페이지입니다.
        각 영화의 포스터, 제목, 감독, 연도, 장르, 평점, 폭력성 평균, 개요(요약), IMDb ID를 보여줍니다.
        관리자는 이 페이지에서 영화를 '수정'하거나 '삭제'할 수 있는 버튼을 추가로 볼 수 있습니다.

    목적:
        - 시스템에 등록된 모든 영화 정보를 한눈에 볼 수 있도록 합니다.
        - 영화 제목 클릭 시 상세 페이지로 이동하여 더 많은 정보를 확인하도록 유도합니다.
        - 관리자에게는 등록된 영화를 직접 관리(수정, 삭제)할 수 있는 기능을 제공합니다.
        - API에서 가져온 영화와 수동으로 등록된 영화 모두를 일관된 형식으로 표시합니다.

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head><title>영화 관리</title></head>
<body>
<h1>영화 관리</h1>

<%--
    관리자에게만 보이는 관리 기능 링크
    목적: 관리자만 영화를 API에서 검색하거나 직접 등록할 수 있는 페이지로 이동하는 링크를 제공합니다.
    `userRole == 'ADMIN'`: `movieController.java`에서 세션에 저장된 사용자 역할(`userRole`)이 'ADMIN'인지 확인합니다.
    `/movies/search-api`: `movieController.java`의 `searchApiMoviesPage` (GET /movies/search-api)로 이동합니다.
    `/movies/new`: `movieController.java`의 `createForm` (GET /movies/new)으로 이동합니다.
--%>
<c:if test="${userRole == 'ADMIN'}">
    <p><a href="<c:url value='/movies/search-api'/>">API에서 영화 검색 및 등록</a></p>
    <p><a href="<c:url value='/movies/new'/>">새 영화 직접 등록</a></p>
</c:if>

<%--
    에러/상태 메시지 표시
    목적: 영화 조회 실패, API 영화 등록 성공 등과 같은 메시지를 사용자에게 피드백합니다.
    `param.error`: `movieController.java`에서 리다이렉트 시 `RedirectAttributes`를 통해 전달되는 쿼리 파라미터입니다.
        - `notFound`: `movieController.detail` 또는 `editForm`에서 영화를 찾지 못했을 때 설정됩니다.
        - `movieNotFound`: `movieController.getApiExternalMovieDetail`에서 API 영화 정보를 찾지 못했을 때 설정됩니다.
    `param.status`: `movieController.importApiMovieDetail`에서 API 영화 등록 성공 시 설정됩니다.
--%>
<c:if test="${not empty param.error}">
    <p style="color: red;">${param.error == 'notFound' ? '요청하신 영화를 찾을 수 없습니다.' : (param.error == 'movieNotFound' ? '영화 정보를 찾을 수 없거나 API 호출에 실패했습니다.' : '알 수 없는 오류가 발생했습니다.')}</p>
</c:if>
<c:if test="${not empty param.status && param.status == 'registered'}">
    <p style="color: green;">API에서 영화 정보가 성공적으로 등록되었습니다!</p>
</c:if>

<table border="1">
    <tr>
        <th>포스터</th>
        <th>제목</th>
        <th>감독</th>
        <th>연도</th>
        <th>장르</th>
        <th>평점</th>
        <th>폭력성</th>
        <th>개요</th>
        <th>IMDb ID</th>
        <%-- 관리자에게만 '관리' 열 표시--%>
        <c:if test="${userRole == 'ADMIN'}">
            <th>관리</th>
        </c:if>
    </tr>
    <%--
        `c:forEach` 루프: `movies` 리스트의 각 `movie` 객체에 대해 반복합니다.
        `var="movie"`: 현재 반복 중인 `movie` 객체를 참조할 변수 이름입니다.
        `items="${movies}"`: `movieController.list` 메서드에서 `model.addAttribute("movies", movieService.findAll());`를 통해 전달된 영화 목록입니다.
    --%>
    <c:forEach var="movie" items="${movies}">
        <tr>
            <td>
                <%--
                    포스터 이미지 표시
                    `movie.posterPath`: `movie` 도메인 객체의 `posterPath` 필드에서 이미지 경로를 가져옵니다.
                    `fn:startsWith(..., 'http://')` 또는 `https://`:
                        - JSTL Functions 라이브러리(`fn`)를 사용하여 `posterPath`가 완전한 URL인지 확인합니다.
                        - 외부 API(OMDb)에서 가져온 이미지는 외부 URL이므로 직접 사용합니다.
                        - 직접 업로드된 이미지(예: `/resources/images/movies/`)는 애플리케이션의 컨텍스트 경로를 붙여줍니다.
                        - `movieController.java`에서 이미지 저장 시 `UPLOAD_DIRECTORY_RELATIVE` 상수를 사용하여 경로를 설정합니다.
                    `default_poster.jpg`:
                        - `movie.posterPath`가 비어있거나 "N/A" 값일 경우 표시되는 기본 포스터 이미지입니다.
                        - `externalMovieApiService`에서 포스터 정보가 없을 때 "N/A"로 설정합니다.
                        - `movieController`에서 업로드된 파일이 없을 때 `movie.setPosterPath(null)`로 설정될 수 있습니다.
                --%>
                <c:set var="posterSrc">
					<c:choose>
					    <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
					        <c:choose>
					            <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
					                <c:set var="posterSrc" value="${movie.posterPath}" />
					            </c:when>
					            <c:otherwise>
					                <c:set var="posterSrc" value="${pageContext.request.contextPath}${movie.posterPath}" />
					            </c:otherwise>
					        </c:choose>
					    </c:when>
					    <c:otherwise>
					        <c:set var="posterSrc" value="${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png" />
					    </c:otherwise>
					</c:choose>
                </c:set>
                <img src="${posterSrc}" alt="${movie.title} 포스터" style="width: 100px; height: auto;" />
            </td>
            <td><a href="<c:url value='/movies/${movie.id}'/>">${movie.title}</a></td>
            <%-- 영화 기타 정보 표시--%>
            <td>${movie.director}</td>
            <td>${movie.year}</td>
            <td>${movie.genre}</td>
            <td>
 
                <c:choose>
                    <c:when test="${movie.rating == 0.0}">
                        N/A <%-- 평점이 0.0이면 N/A 표시--%>
                    </c:when>
                    <c:otherwise>
                        <fmt:formatNumber value="${movie.rating}" pattern="#0.0" />
                    </c:otherwise>
                </c:choose>
            </td>
            <td>
  
                <c:choose>
                    <c:when test="${movie.violence_score_avg == 0.0}">
                        N/A <%-- 폭력성 평균이 0.0이면 N/A 표시--%>
                    </c:when>
                    <c:otherwise>
                        <fmt:formatNumber value="${movie.violence_score_avg}" pattern="#0.0" />
                    </c:otherwise>
                </c:choose>
            </td>
            <td>${fn:substring(movie.overview, 0, 30)}...</td>
            <td>${movie.apiId}</td>
            <%--
                관리자에게만 '수정'/'삭제' 버튼 표시
                `userRole == 'ADMIN'`: `movieController.java`에서 세션에 저장된 사용자 역할(`userRole`)이 'ADMIN'인지 확인합니다.
            --%>
            <c:if test="${userRole == 'ADMIN'}">
                <td>
   
                    <a href="<c:url value='/movies/${movie.id}/edit'/>">수정</a>

                    <form action="<c:url value='/movies/${movie.id}/delete'/>" method="post" style="display:inline">
                        <button type="submit">삭제</button>
                    </form>
                </td>
            </c:if>
        </tr>
    </c:forEach>
    <%--
        영화 목록이 비어있는 경우 메시지 표시
        `empty movies`: `movieController.list`에서 전달된 `movies` 리스트가 비어있는지 확인합니다.
        `colspan`: 테이블 헤더의 열 개수에 맞춰 `colspan` 값을 조정하여 중앙 정렬된 메시지를 표시합니다.
            - 관리자일 경우 '관리' 열 포함 10개 열 (포스터, 제목, 감독, 연도, 장르, 평점, 폭력성, 개요, IMDb ID, 관리)
            - 일반 사용자일 경우 '관리' 열 제외 9개 열
    --%>
    <c:if test="${empty movies}">
        <tr>
            <c:choose>
                <c:when test="${userRole == 'ADMIN'}">
                    <td colspan="10">등록된 영화가 없습니다.</td>
                </c:when>
                <c:otherwise>
                    <td colspan="9">등록된 영화가 없습니다.</td>
                </c:otherwise>
            </c:choose>
        </tr>
    </c:if>
</table>
</body>
</html>