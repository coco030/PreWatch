<%--
    파일명: detailPage.jsp
    설명:
        이 JSP 파일은 특정 영화의 상세 정보를 표시하는 페이지입니다.
        데이터베이스에 저장된 영화 정보 또는 OMDb API에서 가져온 영화 정보를 기반으로 동작합니다.
        영화의 제목, 감독, 연도, 장르, 개요, 포스터, 그리고 (로컬 DB 기반의) 평점 및 폭력성 평균을 보여줍니다.

    목적:
        - 사용자에게 선택된 영화의 상세 정보를 직관적으로 제공합니다.
        - 외부 API(OMDb)에서 가져온 정보와 로컬 DB의 정보를 통합하여 보여줌으로써, 평점 및 잔혹도와 같이 사이트에서 관리하는 주요 정보를 강조합니다.

--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> 
<%System.out.println("영화 상세페이지 진입"); %>
<html>
<head>
    <meta charset="UTF-8">
    <title>PreWatch: 상세</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
</head> 
<%-- 헤더 --%>
<jsp:include page="/WEB-INF/views/layout/header.jsp" />

<%-- 폭력성 주의문구 띄우기--%>
	<c:import url="/review/sensitivity">
	 <c:param name="movieId" value="${movie.id}" />
	</c:import>   
<%-- // 폭력성 주의문구 띄우기--%>
 
<h1>${movie.title}</h1>
<%--
        포스터 이미지 표시
        목적: 영화의 포스터 이미지를 사용자에게 시각적으로 보여줍니다.
        `movie.posterPath`: `movie` 도메인 객체의 `posterPath` 필드에서 이미지 경로를 가져옵니다.
        `fn:startsWith(..., 'http://')` 또는 `https://`:
            - JSTL Functions 라이브러리(`fn`)를 사용하여 `posterPath`가 완전한 URL인지 확인합니다.
            - 외부 API(OMDb)에서 가져온 이미지는 외부 URL(`http` 또는 `https`로 시작)이므로 그대로 사용합니다.
            - 직접 업로드된 이미지(예: `/resources/images/movies/`)는 애플리케이션의 컨텍스트 경로를 붙여줍니다.
            - `movieController.java`에서 이미지 저장 시 `UPLOAD_DIRECTORY_RELATIVE` 상수를 사용하여 경로를 설정합니다.
        `default_poster.jpg`:
            - `movie.posterPath`가 비어있거나 "N/A" 값일 경우 표시되는 기본 포스터 이미지입니다.
            - `externalMovieApiService`에서 포스터 정보가 없을 때 "N/A"로 설정합니다.
            - `movieController`에서 업로드된 파일이 없을 때 `movie.setPosterPath(null)`로 설정될 수 있습니다.
    --%>
<c:if test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
        <c:set var="posterSrc">
            <c:choose>
                <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                    ${movie.posterPath}
                </c:when>
                <c:otherwise>
                    ${pageContext.request.contextPath}${movie.posterPath}
                </c:otherwise>
            </c:choose>
        </c:set>
        <img src="${posterSrc}" alt="${movie.title} 포스터" style="max-width: 300px; height: auto;" /><br/>
    </c:if>
    <%-- 포스터가 없는 경우 메시지 표시--%>
    <c:if test="${empty movie.posterPath or movie.posterPath eq 'N/A'}">
        <p>(이미지 없음)</p>
    </c:if>
    <%-- 영화 기본 정보 표시--%>
    <p>감독: ${movie.director}</p>
    <p>연도: ${movie.year}</p>
    <p>장르: ${movie.genre}</p>

    <p>평점:
        <%--
            평점 표시 로직
            목적: 평점(`movie.rating`)이 `0.0`인 경우 "N/A" (Not Available)로 표시하고, 그렇지 않으면 소수점 첫째 자리까지 포맷팅하여 보여줍니다.
            `movie.rating`: `movie` 도메인 객체의 평점 필드입니다.
            `externalMovieApiService.java`: OMDb API에서 평점을 가져오지 않고 기본적으로 `0.0`으로 설정합니다.
            `movieController.java`:
                - API 검색 결과를 상세 페이지로 전달할 때 `overrideRatingsWithLocalData`를 통해 로컬 DB의 평점으로 덮어씌웁니다.
                - 로컬 DB에 해당 영화가 없다면 `0.0`이 유지됩니다.
            `fmt:formatNumber`: `fmt` 태그 라이브러리를 사용하여 숫자를 지정된 패턴(`pattern="#0.0"`)으로 포맷팅합니다.
        --%>
        <c:choose>
            <c:when test="${movie.rating == 0.0}">
                N/A
            </c:when>
            <c:otherwise>
                <fmt:formatNumber value="${movie.rating}" pattern="#0.0" />
            </c:otherwise>
        </c:choose>
        / 10.0
    </p>
    <p>폭력성 평균:
        <c:choose>
            <c:when test="${movie.violence_score_avg == 0.0}">
                N/A
            </c:when>
            <c:otherwise>
                <fmt:formatNumber value="${movie.violence_score_avg}" pattern="#0.0" />
            </c:otherwise>
        </c:choose>
        / 10.0
    </p>
    <p>개요: ${movie.overview}</p>
<hr>

<!-- 영화 상세페이지 하단에 태그 전체 출력 -->
<c:import url="/review/tags">
    <c:param name="movieId" value="${movie.id}" />
</c:import>
<!--// 영화 상세페이지 하단에 태그 전체 출력 -->


 <%-- 영화 상세 페이지 아래의 모든 사용자 리뷰 --%>
<c:if test="${not empty sessionScope.loginMember}">
    <c:import url="/review/form">
        <c:param name="movieId" value="${movie.id}" />
    </c:import>
</c:if>
 <%-- // 영화 상세 페이지 아래의 모든 사용자 리뷰 --%>
 <c:import url="/review/list">
    <c:param name="movieId" value="${movie.id}" />
</c:import>
 
 <%-- 푸터 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</body>
</html>
