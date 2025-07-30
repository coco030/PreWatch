<%--
    파일명: recommendedMoviesList.jsp
    설명: 이 JSP 파일은 '모든 추천 랭킹 영화' 목록을 표시하는 페이지입니다.
          `movieController`의 특정 메서드로부터 `recommendedMovies` 리스트를 받아와
          그리드 형태로 영화 정보를 표시합니다.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>모든 추천 랭킹 영화</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
<style>
/* recentMoviesList.jsp와 동일한 스타일 적용 (필요에 따라 layout.css로 이동 권장) */
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

.section-title {
    font-size: 20px;
    margin-bottom: 15px;
    border-bottom: 2px solid #eee;
    padding-bottom: 10px;
    width: 100%;
    text-align: left;
    box-sizing: border-box;
}

.movie-card {
    background-color: #fff;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    text-align: center;
    padding-bottom: 15px;
    position: relative;
    height: 100%; /* 카드 높이를 부모와 동일하게 */
}

/* 추천 랭킹 배지 스타일 */
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

.movie-card img {
    width: 100%;
    height: 380px; /* ⭐ 이미지 높이를 다시 380px로 설정 ⭐ */
    object-fit: cover;
    border-bottom: 1px solid #eee;
}

.movie-card h5 {
    font-size: 16px;
    margin: 10px 0 5px;
    padding: 0 10px;
    font-weight: bold;
}

.movie-card p {
    font-size: 14px;
    color: #666;
    margin: 0;
    padding: 0 10px;
}

.movie-card a {
    text-decoration: none;
    color: inherit;
    display: block; /* 링크가 카드 전체를 감싸도록 */
    height: 100%;
}

.movie-card a:hover h5 {
    color: #007bff;
}

.no-movies-message {
    text-align: center;
    margin: 40px;
    font-size: 1.2em;
    color: #888;
}
</style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <main class="container py-4">
        <h2 class="section-title">모든 추천 랭킹 영화</h2>

        <c:choose>
            <c:when test="${not empty recommendedMovies}">
                <div class="row g-4 justify-content-center">
                    <c:set var="rank" value="0" />
                    <c:forEach var="movie" items="${recommendedMovies}">
                        <c:set var="rank" value="${rank + 1}" />
                        <%-- ⭐ 컬럼 크기 조정: 여기를 변경하여 한 줄에 표시되는 카드 수를 조절할 수 있습니다. ⭐ --%>
                        <%-- 예: col-lg-3 (한 줄에 4개), col-lg-2 (한 줄에 6개) --%>
                        <div class="col-6 col-md-4 col-lg-3">
                            <div class="movie-card">
                                <div class="rank-badge">${rank}</div>
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
                                                ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                                            </c:otherwise>
                                        </c:choose>
                                    </c:set>
                                    <img src="${posterSrc}" alt="${movie.title} 포스터" />
                                    <div class="p-3">
                                        <h5 class="fw-bold">${movie.title}</h5>
                                        <p class="text-muted mb-1">${movie.year} | ${movie.genre}</p>
                                        <p class="text-muted mb-0">찜 : ${movie.likeCount}</p>
                                    </div>
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <p class="no-movies-message">등록된 추천 영화 랭킹이 없습니다.</p>
            </c:otherwise>
        </c:choose>
    </main>

    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>