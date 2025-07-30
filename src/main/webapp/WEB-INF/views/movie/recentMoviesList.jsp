<%--
    파일명: recentMoviesList.jsp
    설명: 이 JSP 파일은 '모든 최근 등록된 영화' 목록을 표시하는 페이지입니다.
          `movieController`의 `allRecentMovies` 메서드로부터 `recentMovies` 리스트를 받아와
          그리드 형태로 영화 정보를 표시합니다.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% System.out.println("recentMoviesList 뷰 진입"); %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>모든 최근 등록 영화</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
<style>
/* ⚠️ 주의: 이 <style> 태그 안의 CSS는 layout.css에 공통으로 빼거나,
   이 JSP에만 필요한 경우 여기에 유지하세요.
   wishlist.jsp에 있던 CSS와 겹치는 부분이 많습니다.
   현재는 기존 제공된 CSS를 포함했습니다. */

.main-content-wrapper {
    display: flex;
    flex-direction: column;
    gap: 0;
    align-items: center;
    max-width: 1200px;
    margin: 20px auto;
    padding: 0;
    background-color: transparent;
    box-shadow: none;
    border-radius: 0;
}

/* 찜 목록 관련 CSS 제거 또는 이름 변경 */
/* .wishlist.container { ... } (제거 또는 사용 안 함) */
/* .wishlist .movie-grid { ... } (제거 또는 사용 안 함) */

/* 개별 섹션 컨테이너 스타일 (main.container와 second_container에 공통 적용) */
/* 이 페이지는 단일 목록이므로 .second_container 등을 사용할 필요가 없을 수도 있습니다. */
/* 하지만 기존 구조를 유지하기 위해 그대로 두겠습니다. */
.main.container, .second_container, .third_container {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
    padding: 20px;
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    box-sizing: border-box;
}

.main.container { margin-bottom: 0; }
.second_container { margin-top: 0; }
.third_container { margin-top: 0; }

/* 섹션 제목 스타일 - 아래줄 포함 */
.section-title {
    font-size: 20px;
    margin-bottom: 15px;
    border-bottom: 2px solid #eee;
    padding-bottom: 10px;
    width: 100%;
    text-align: left;
    box-sizing: border-box;
}

/* 영화 카드 레이아웃: 반응형 그리드 */
/* 이 페이지의 주 목적에 맞는 그리드 설정 */
.movie-grid { /* 이 페이지의 메인 그리드가 될 것입니다. */
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); /* 유연한 그리드 */
    gap: 20px;
    max-width: 1090px; /* 메인 콘텐츠 너비에 맞춤 */
    width: 100%;
    margin: 0 auto;
    justify-content: center;
}

/* 개별 영화 카드 스타일 */
.movie-card {
    background-color: #fff;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    text-align: center;
    padding-bottom: 15px;
    position: relative;
}

/* 순위 배지 스타일 (NEW 영화에만 해당) */
.movie-card .rank-badge {
    position: absolute;
    top: 10px;
    left: 10px;
    background-color: rgba(100, 100, 100, 0.8);
    color: white;
    font-size: 1.1em;
    font-weight: bold;
    padding: 5px 8px;
    border-radius: 5px;
    z-index: 10;
    min-width: 25px;
    text-align: center;
}

/* 영화 포스터 이미지 크기 고정 + 비율 유지 (이 페이지에 맞게 조정) */
.movie-card img {
    width: 100%;
    height: 380px; /* 고정 높이 */
    object-fit: cover;
    border-bottom: 1px solid #eee; /* 포스터와 텍스트 분리선 */
}

/* 영화 제목 스타일 */
.movie-card h5 { /* H5 태그 사용에 맞게 스타일 조정 */
    font-size: 16px;
    margin: 10px 0 5px;
    padding: 0 10px;
    font-weight: bold; /* main.jsp와 일관성을 위해 추가 */
}

/* 영화 정보 텍스트 (장르, 연도 등) */
.movie-card p {
    font-size: 14px;
    color: #666;
    margin: 0;
    padding: 0 10px;
}

/* 카드 전체 링크 스타일 초기화 */
.movie-card a {
    text-decoration: none;
    color: inherit;
}

/* 링크에 마우스 올렸을 때 제목만 색 강조 */
.movie-card a:hover h5 {
    color: #007bff;
}

/* 찜한 영화가 없을 때 메시지 스타일 (이 페이지에는 "최근 영화가 없음"으로 사용) */
.no-movies-message {
    text-align: center;
    margin: 40px;
    font-size: 1.2em;
    color: #888;
}

</style>
</head>
<body>
    <%-- 헤더 --%>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <%--
        ⭐ 이 페이지의 메인 콘텐츠 컨테이너입니다.
        클래스를 'container py-4'로 변경하여 Bootstrap의 기본 컨테이너 패딩을 활용하고,
        이전 wishlist.jsp의 .second_container 대신 단독으로 사용합니다.
    --%>
    <main class="container py-4">
        <h2 class="section-title">모든 최근 등록된 영화</h2>

        <c:choose>
            <%-- ⭐ 중요 수정: 컨트롤러에서 전달하는 'recentMovies' 리스트가 비어있는지 확인합니다. ⭐ --%>
            <c:when test="${not empty recentMovies}">
                <div class="row g-4 justify-content-center"> <%-- Bootstrap 그리드 row 사용 --%>
                    <%-- ⭐ 중요 수정: 'recentMovies' 리스트를 반복하고, begin/end 속성을 제거하여 모든 영화를 표시합니다. ⭐ --%>
                    <c:forEach var="movie" items="${recentMovies}">
                        <div class="col-6 col-md-4 col-lg-3"> <%-- Bootstrap 컬럼 클래스 사용 --%>
                            <div class="movie-card">
                                <div class="rank-badge">NEW</div> <%-- 'NEW' 배지 (최근 등록 영화이므로) --%>
                                <a href="<c:url value='/movies/${movie.id}'/>">
                                    <c:set var="posterSrc">
                                        <c:choose>
                                            <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                                                <c:choose>
                                                    <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                                                        ${movie.posterPath}
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${pageContext.request.contextPath}${movie.posterPath}
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>
                                                <%-- 기본 포스터 이미지 경로를 명확히 합니다. --%>
                                                ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                                            </c:otherwise>
                                        </c:choose>
                                    </c:set>
                                    <img src="${posterSrc}" alt="${movie.title} 포스터" />
                                    <div class="p-3">
                                        <h5 class="fw-bold">${movie.title}</h5>
                                        <p class="text-muted mb-1">${movie.year} | ${movie.genre}</p>
                                        <p class="text-muted mb-0">평점: <fmt:formatNumber value="${movie.rating}" pattern="#0.0" /></p>
                                        <%-- 폭력성 지수는 필요하다면 추가 --%>
                                        <%-- <p class="text-muted mb-0">폭력성 지수: <fmt:formatNumber value="${movie.violenceScoreAvg}" pattern="#0.0" /></p> --%>
                                    </div>
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <%-- 최근 영화가 없을 때 메시지 --%>
                <p class="no-movies-message">등록된 최근 영화가 없습니다.</p>
            </c:otherwise>
        </c:choose>
    </main>

    <%-- 푸터 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>